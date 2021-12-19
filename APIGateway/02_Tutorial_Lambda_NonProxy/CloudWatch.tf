resource "aws_cloudwatch_log_group" "Cloudwatch_Log_Group" {
  name              = "/aws/lambda/${aws_lambda_function.Lambda_Function.function_name}"
  retention_in_days = 1
}