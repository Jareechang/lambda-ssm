provider "aws" {
  version = "~> 2.0"
  region  = "${var.aws_region}"
}

locals {
  package_json = jsondecode(file("./package.json"))
  build_folder = "src"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "lambda-ssm-test123"
  acl           = "private"
  region        = "${var.aws_region}"

  tags = {
    Name        = "Dev Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "lambda_ssm_test" {
  bucket = "${aws_s3_bucket.lambda_bucket.id}"
  key = "main-${local.package_json.version}"
  source = "main-${local.package_json.version}.zip"
  etag = "${filemd5("./main-${local.package_json.version}.zip")}"
}

resource "aws_lambda_function" "test_lambda" {
  function_name = var.lambda_func_name
  s3_bucket = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key = "${aws_s3_bucket_object.lambda_ssm_test.id}"
  handler = "src/index.handler"
  role = "${aws_iam_role.default.arn}"
  timeout = 300

  source_code_hash = "${filebase64sha256("./main-${local.package_json.version}.zip")}"

  runtime = "nodejs12.x"
  depends_on = [
    "aws_iam_role_policy_attachment.default",
    "aws_cloudwatch_log_group.sample_log_group"
  ]

  environment {
    variables = {
      envPath = "/dev/application"
    }
  }
}

resource "aws_cloudwatch_log_group" "sample_log_group" {
    name = "/aws/lambda/${var.lambda_func_name}"
    retention_in_days = 1
}


resource "aws_kms_key" "default" {
  description             = "Default encryption key (symmetric)"
  deletion_window_in_days = 10
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/dev/application/datbase/password"
  description = "Datbase password"
  type        = "SecureString"
  key_id      = aws_kms_key.default.key_id
  value       = var.database_password
  tags = {
    environment = "dev"
  }
}

resource "aws_ssm_parameter" "random" {
  name        = "/dev/application/random"
  description = "Random config"
  type        = "String"
  value       = "some other random config"
  tags = {
    environment = "dev"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions   = ["ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.ssm_parameters_base}"
    ]
    effect    = "Allow"
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${aws_kms_key.default.arn}"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "default" {
  name        = "AllowBasicSSMActionPolicy"
  description = "Allow SSM actions"
  policy      = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_role" "default" {
  name                 = "AllowGetSSMParametersRole"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  description          = "IAM Role with permissions to perform actions on SSM resources"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}
