provider "aws" {
  region = "eu-west-1"
}

###################################
############ DYNAMODB #############
###################################

# Declare DynamoDB table
resource "aws_dynamodb_table" "ProductInventory" {
  name           = "ProductInventory"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ProductID"
  attribute {
    name = "ProductID"
    type = "S"
  }
}

###################################
############# LAMBDA ##############
###################################

# Declare Assume role policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Declare role
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Declare policies that need to be attached to the lambda role
data "aws_iam_policy" "AmazonDynamoDBFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "CloudWatchFullAccessV2" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccessV2"
}

# Attach policies to the Lambda execution role
resource "aws_iam_role_policy_attachment" "dynamodb_access_attachment" {
  policy_arn = data.aws_iam_policy.AmazonDynamoDBFullAccess.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access_attachment" {
  policy_arn = data.aws_iam_policy.CloudWatchFullAccessV2.arn
  role       = aws_iam_role.iam_for_lambda.name
}

# Create lambda zip file
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = "serverless-api"
  output_path = "lambda_function.zip"
}

# Declare lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name = "serverless-api"
  filename         = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
}


###################################
######### API GATEWAY #############
###################################
#
# API Gateway Integration with Lambda example:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration#lambda-integration
#

# Declare API Gateway
resource "aws_api_gateway_rest_api" "serverless_api" {
  name        = "serverless-api"
  description = "Serverless API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Declare API Gateway resource
resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api.id
  parent_id   = aws_api_gateway_rest_api.serverless_api.root_resource_id
  path_part   = "product"
}

# Declare API Gateway POST method
resource "aws_api_gateway_method" "api_gateway_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_api.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Declare API Gateway integration for POST method with lambda
resource "aws_api_gateway_integration" "api_gateway_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_post_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_function.invoke_arn
}

# Declare API Gateway GET method
# Note integration_http_method must be POST for all methods
# https://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html
resource "aws_api_gateway_method" "api_gateway_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_api.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Declare API Gateway integration for GET method with lambda
resource "aws_api_gateway_integration" "api_gateway_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_get_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_function.invoke_arn
}

# Declare API Gateway DELETE method
resource "aws_api_gateway_method" "api_gateway_delete_method" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_api.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# Declare API Gateway integration for DELETE method with lambda
resource "aws_api_gateway_integration" "api_gateway_delete_integration" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_delete_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_function.invoke_arn
}

# Giving API Gateway permissions to access the Lambda function
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  # source_arn = "*"
}

# Declare API Gateway deployment
resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api.id
  depends_on = [ aws_api_gateway_integration.api_gateway_get_integration,
    aws_api_gateway_integration.api_gateway_post_integration,
    aws_api_gateway_integration.api_gateway_delete_integration ]
}

# Declare API Gateway stage
resource "aws_api_gateway_stage" "api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.serverless_api.id
  stage_name    = "Development"
}
