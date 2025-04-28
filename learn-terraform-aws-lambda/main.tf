# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      hashicorp-learn = "lambda-api-gateway"
    }
  }

}

// Create a random name for the S3 bucket to store the Lambda function code
// The name must be globally unique across all AWS accounts
// The random_pet resource generates a unique name using a prefix and a random suffix
// The length parameter specifies the number of words in the random name
// The prefix is used to create a more meaningful name
resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-functions"
  length = 4
}

// Create an S3 bucket to store the Lambda function code
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

// Enable versioning for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// Set the ownership controls for the S3 bucket
resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]

  bucket = aws_s3_bucket.lambda_bucket.id
  // The canned_acl is used to set the access control list for the bucket
  // privaete means that only the bucket owner has access to the objects in the bucket
  acl    = "private"
}

// Zip the Lambda function code
// The archive_file data source creates a zip file from the source_dir
// The source_dir is the directory containing the Lambda function code
// The output_path is the path to the zip file
// The type is set to "zip" to create a zip file

data "archive_file" "lambda_hello_world" {
  type = "zip"

  source_dir  = "${path.module}/hello-world"
  output_path = "${path.module}/hello-world.zip"
}

// Upload the zip file to the S3 bucket
resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path
  // The etag is used to identify the version of the object in S3
  // The etag is a hash of the object data
  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}

// Create lambda function resource from the zip file in S3
resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs20.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Clean up the local zip file after upload
// The null_resource is used to run a local command after the S3 object is created
// The depends_on argument ensures that the command is run after the S3 object is created
resource "null_resource" "cleanup_zip" {
    depends_on = [aws_s3_object.lambda_hello_world]

    provisioner "local-exec" {
        command = "rm -f ${data.archive_file.lambda_hello_world.output_path}"
    }
}

// Create an API Gateway to trigger the Lambda function
// The aws_apigatewayv2_api resource creates an HTTP API Gateway
// This is the main entry point for HTTP requests
resource "aws_apigatewayv2_api" "lambda" {
    name          = "serverless_lambda_gw"
    protocol_type = "HTTP"
}

// Create a stage for the API Gateway
// A stage is a named reference to a deployment of the API
// This configuration enables automatic deployments and logging
resource "aws_apigatewayv2_stage" "lambda" {
    api_id = aws_apigatewayv2_api.lambda.id

    name        = "serverless_lambda_stage"
    auto_deploy = true

    access_log_settings {
        destination_arn = aws_cloudwatch_log_group.api_gw.arn

        format = jsonencode({
            requestId               = "$context.requestId"
            sourceIp                = "$context.identity.sourceIp"
            requestTime             = "$context.requestTime"
            protocol                = "$context.protocol"
            httpMethod              = "$context.httpMethod"
            resourcePath            = "$context.resourcePath"
            routeKey                = "$context.routeKey"
            status                  = "$context.status"
            responseLength          = "$context.responseLength"
            integrationErrorMessage = "$context.integrationErrorMessage"
            }
        )
    }
}

// Create an integration between the API Gateway and Lambda function
// This defines how the API Gateway should interact with the Lambda function
// AWS_PROXY integration type means the request is sent directly to Lambda
resource "aws_apigatewayv2_integration" "hello_world" {
    api_id = aws_apigatewayv2_api.lambda.id

    integration_uri    = aws_lambda_function.hello_world.invoke_arn
    integration_type   = "AWS_PROXY"
    integration_method = "POST"
}

// Define the API route that triggers the Lambda function
// This creates a GET /hello endpoint that will invoke the Lambda
resource "aws_apigatewayv2_route" "hello_world" {
    api_id = aws_apigatewayv2_api.lambda.id

    route_key = "GET /hello"
    target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
}

// Create a CloudWatch log group for API Gateway logs
// This enables logging for the API Gateway with 30-day retention
resource "aws_cloudwatch_log_group" "api_gw" {
    name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

    retention_in_days = 30
}

// Grant API Gateway permission to invoke the Lambda function
// This creates the necessary IAM permissions for the integration to work
resource "aws_lambda_permission" "api_gw" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.hello_world.function_name
    principal     = "apigateway.amazonaws.com"

    source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
