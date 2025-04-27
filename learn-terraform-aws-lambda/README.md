# Learn Terraform Lambda + API Gateway
Follow repo: [learn-terraform-lambda-api-gateway](https://github.com/hashicorp-education/learn-terraform-lambda-api-gateway)

Multiple steps in this tutorial:
1. Random Name Generator
2. Create S3 bucket to store the Lambda function code
2. Use the `archive_file` data source to generate a zip archive and an `aws_s3_object` resource to upload the archive to your S3 bucket.

## AWS Configuration
Create an IAM User and set the following configurations.
* Get Access Keys and Set environment variables (Do not share, exposure, or commit to public domains)
    - `export AWS_ACCESS_KEY_ID=""`
    - `export AWS_SECRET_ACCESS_KEY=""`
* Attach Policies to IAM User
    - `AmazonEC2FullAccess`
    - `AmazonS3FullAccess`

### Creating an EC2 instance
Terraform configuration to define a single AWS EC2 instance

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3" # us-west-2
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

```

### Potential Errors

│ Error: Failed to query available provider packages

Fix: `terraform init -upgrade`