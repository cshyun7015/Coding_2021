resource "aws_api_gateway_rest_api" "Api_Gateway_Rest_Api" {
  name = "ib07441-rest-api-lambda-proxy"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# resource "aws_api_gateway_authorizer" "Api_Gateway_Authorizer" {
#   name                   = "ib07441-authorizer"
#   rest_api_id            = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id

#   type = "COGNITO_USER_POOLS"
#   provider_arns = [aws_cognito_user_pool.Cognito_User_Pool.arn]
#   identity_source = "method.request.header.Authorization"
# }

resource "aws_api_gateway_resource" "Api_Gateway_Resource" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  parent_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.root_resource_id
  path_part   = "helloworld"
}

resource "aws_api_gateway_method" "Api_Gateway_Method" {
  rest_api_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id   = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "Api_Gateway_Integration" {
  rest_api_id             = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id             = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method             = aws_api_gateway_method.Api_Gateway_Method.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Lambda_Function.invoke_arn
}

resource "aws_api_gateway_deployment" "Api_Gateway_Deployment" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id

  # triggers = {
  #   redeployment = sha1(jsonencode(aws_api_gateway_rest_api.Api_Gateway_Rest_Api.body))
  # }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "Api_Gateway_Stage" {
  deployment_id = aws_api_gateway_deployment.Api_Gateway_Deployment.id
  rest_api_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  stage_name    = "test"
}

output "Api_Gateway_Rest_Api_Id" {
  value = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
}