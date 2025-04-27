# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Output value definitions

// This file contains the output values for the Terraform configuration
// for the AWS Lambda function and S3 bucket.
// The output values are used to display information about the resources
output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_bucket.id
}