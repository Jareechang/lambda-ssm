output "ssm_arn" {
  value = aws_ssm_parameter.db_password.arn
}
