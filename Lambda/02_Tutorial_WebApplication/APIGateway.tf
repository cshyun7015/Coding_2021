resource "aws_api_gateway_rest_api" "Api_Gateway_Rest_Api" {
  name = "ib07441-rest-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "Api_Gateway_Authorizer" {
  name                   = "ib07441-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id

  type = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.Cognito_User_Pool.arn]
  identity_source = "method.request.header.Authorization"
}

resource "aws_api_gateway_resource" "Api_Gateway_Resource" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  parent_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.root_resource_id
  path_part   = "/ride"
}

resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id   = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "Api_Gateway_Deployment" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.Api_Gateway_Rest_Api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "Api_Gateway_Stage" {
  deployment_id = aws_api_gateway_deployment.Api_Gateway_Deployment.id
  rest_api_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  stage_name    = "prod"
}