resource "aws_lambda_function" "Lambda_Function" {
  function_name = "ib07441-Lambda-Proxy"
  role          = aws_iam_role.IamRole_LambdaTrustRole.arn
  handler       = "index.handler"

  s3_bucket = aws_s3_bucket.S3Bucket.id
  s3_key = aws_s3_bucket_object.S3_Bucket_Object.key

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(aws_s3_bucket_object.S3_Bucket_Object.key)

  runtime = "nodejs10.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_permission" "Lambda_Permission" {
  statement_id  = "AllowIB07441APIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "ib07441-Lambda-Proxy"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.Api_Gateway_Rest_Api.execution_arn}/*/*/*"
}

data "aws_lambda_invocation" "Lambda_Invocation" {
  function_name = aws_lambda_function.Lambda_Function.function_name

  input = <<JSON
{
    "path": "/helloworld",
    "httpMethod": "POST",
    "headers": {
        "Accept": "*/*",
        "Authorization": "eyJraWQiOiJLTzRVMWZs",
        "content-type": "application/json; charset=UTF-8"
    },
    "queryStringParameters": null,
    "pathParameters": null,
    "requestContext": {
        "authorizer": {
            "claims": {
                "cognito:username": "the_username"
            }
        }
    },
    "body": "{\"PickupLocation\":{\"Latitude\":47.6174755835663,\"Longitude\":-122.28837066650185}}"
}
JSON
}

output "result_entry" {
  value = jsondecode(data.aws_lambda_invocation.Lambda_Invocation.result)
}