resource "aws_lambda_function" "Lambda_Function" {
  function_name = "IB07441-Pipeline-Notification"
  runtime = "nodejs12.x"
  role          = aws_iam_role.IamRole_LambdaTrustRole.arn
  filename      = "./source_code/index.zip"
  handler       = "index.handler"
}