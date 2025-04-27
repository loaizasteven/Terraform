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
