resource "aws_api_gateway_rest_api" "Api_Gateway_Rest_Api" {
  name = "ib07441-rest-api-lambda-nonproxy"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_model" "Api_Gateway_Model" {
  rest_api_id  = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  name         = "ib07441model"
  description  = ""
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "GetStartedLambdaIntegrationInputModel",
  "type": "object",
  "properties": {
    "callerName": { "type": "string" }
  }
}
EOF
}

# resource "aws_api_gateway_request_validator" "Api_Gateway_Request_Validator" {
#   name                        = "example"
#   rest_api_id                 = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
#   validate_request_body       = true
#   validate_request_parameters = true
# }

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
  path_part   = "{city}"
}

resource "aws_api_gateway_method" "Api_Gateway_Method" {
  rest_api_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id   = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method   = "ANY"
  authorization = "NONE"

  #request_validator_id = aws_api_gateway_request_validator.Api_Gateway_Request_Validator.id

  request_parameters = {
    "method.request.header.day" = true 
    "method.request.querystring.time" = true
  }

  request_models = {
    "application/json" = aws_api_gateway_model.Api_Gateway_Model.name
  }
}

resource "aws_api_gateway_integration" "Api_Gateway_Integration" {
  rest_api_id             = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id             = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method             = aws_api_gateway_method.Api_Gateway_Method.http_method
  integration_http_method = "ANY"
  type                    = "AWS"
  uri                     = aws_lambda_function.Lambda_Function.invoke_arn

  request_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "city": "$input.params('city')",
  "time": "$input.params('time')",
  "day":  "$input.params('day')",
  "name": "$inputRoot.callerName"
}
EOF
  }

  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_method_response" "Api_Gateway_Method_Response_200" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method = aws_api_gateway_method.Api_Gateway_Method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "Api_Gateway_Integration_Response" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method = aws_api_gateway_method.Api_Gateway_Method.http_method
  status_code = aws_api_gateway_method_response.Api_Gateway_Method_Response_200.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "Api_Gateway_Deployment" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  description = "Deployed at ${timestamp()}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "Api_Gateway_Stage" {
  deployment_id = aws_api_gateway_deployment.Api_Gateway_Deployment.id
  rest_api_id   = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  stage_name    = "test"
  description = "${timestamp()}"
}

output "Api_Gateway_Rest_Api_Id" {
  value = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
}


# module "api-gateway-enable-cors" {
#   source  = "squidfunk/api-gateway-enable-cors/aws"
#   version = "0.3.3"
#   api_id          = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
#   api_resource_id = aws_api_gateway_resource.Api_Gateway_Resource.id
# }


// 400 응답 매핑
resource "aws_api_gateway_method_response" "status_api_resource_check_post_400" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method = aws_api_gateway_method.Api_Gateway_Method.http_method
  status_code = "400"
  response_models = {
    "application/json" = "Error"
  }
}

resource "aws_api_gateway_integration_response" "status_api_resource_check_post_400" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method = aws_api_gateway_method.Api_Gateway_Method.http_method
  status_code = aws_api_gateway_method_response.status_api_resource_check_post_400.status_code
  selection_pattern = ".*BadRequest.*"
  response_templates = {
    "application/json" = <<EOF
#set ($errorMessageObj = $util.parseJson($input.path('$.errorMessage')))

{
  "message": "$errorMessageObj.message",
  "stack": "$errorMessageObj.stackTrace",
  "requestId": "$errorMessageObj.requestId"
}
EOF
  }
}

// 500 응답 매핑
resource "aws_api_gateway_method_response" "status_api_resource_check_post_500" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method = aws_api_gateway_method.Api_Gateway_Method.http_method
  status_code = "500"
  response_models = {
    "application/json" = "Error"
  }
}

resource "aws_api_gateway_integration_response" "status_api_resource_check_post_500" {
  rest_api_id = aws_api_gateway_rest_api.Api_Gateway_Rest_Api.id
  resource_id = aws_api_gateway_resource.Api_Gateway_Resource.id
  http_method = aws_api_gateway_method.Api_Gateway_Method.http_method
  status_code = aws_api_gateway_method_response.status_api_resource_check_post_500.status_code
  selection_pattern = ".*InternalServerError.*"

  response_templates = {
    "application/json" = <<EOF
#set ($errorMessageObj = $util.parseJson($input.path('$.errorMessage')))

{
  "message": "$errorMessageObj.message",
  "stack": "$errorMessageObj.stackTrace",
  "requestId": "$errorMessageObj.requestId"
}
EOF
  }
}