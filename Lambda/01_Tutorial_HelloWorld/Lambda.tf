resource "aws_lambda_function" "Lambda_Function" {
  function_name = "ib07441-hello-world-python"
  role          = aws_iam_role.IamRole_LambdaTrustRole.arn
  handler       = "hello-world-python.lambda_handler"

  s3_bucket = aws_s3_bucket.S3Bucket.id
  s3_key = aws_s3_bucket_object.S3_Bucket_Object.key

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(aws_s3_bucket_object.S3_Bucket_Object.key)

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

data "aws_lambda_invocation" "Lambda_Invocation" {
  function_name = aws_lambda_function.Lambda_Function.function_name

  input = <<JSON
{
  "key1": "hello, world!",
  "key2": "value2",
  "key3": "value3"
}
JSON
}

output "result_entry" {
  value = jsondecode(data.aws_lambda_invocation.Lambda_Invocation.result)
}