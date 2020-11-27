variable database_password {}
variable aws_account_id {}

variable aws_region {
  default = "us-east-1"
}

variable lambda_func_name {
  default = "lambda-ssm-test"
}

variable ssm_parameters_base {
  default = "dev/application"
}
