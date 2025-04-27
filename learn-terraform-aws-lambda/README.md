# Learn Terraform Lambda + API Gateway
Follow repo: [learn-terraform-lambda-api-gateway](https://github.com/hashicorp-education/learn-terraform-lambda-api-gateway)

Multiple steps in this tutorial:
1. Random Name Generator
2. Create S3 bucket to store the Lambda function code
3. Use the `archive_file` data source to generate a zip archive and an `aws_s3_object` resource to upload the archive to your S3 bucket.
4. Create lambda in aws. This configuration defines four resources:
- - `aws_lambda_function.hello_world` configures the Lambda function to use the bucket object containing your function code. It also sets the runtime to `NodeJS`, and assigns the handler to the handler function defined in `hello.js`. The `source_code_hash` attribute will change whenever you update the code contained in the archive, which lets Lambda know that there is a new version of your code available. Finally, the resource specifies a role which grants the function permission to access AWS services and resources in your account.

- - `aws_cloudwatch_log_group.hello_world` defines a log group to store log messages from your Lambda function for 30 days. By convention, Lambda stores logs in a group with the name `/aws/lambda/<Function Name>`.

- - `aws_iam_role.lambda_exec` defines an IAM role that allows Lambda to access resources in your AWS account.

- - `aws_iam_role_policy_attachment.lambda_policy` attaches a policy the IAM role. The `AWSLambdaBasicExecutionRole` is an AWS managed policy that allows your Lambda function to write to CloudWatch logs.

## AWS Configuration
Create an IAM User and set the following configurations.
* Get Access Keys and Set environment variables (Do not share, exposure, or commit to public domains)
    - `export AWS_ACCESS_KEY_ID=""`
    - `export AWS_SECRET_ACCESS_KEY=""`
* Attach Policies to IAM User
    - `AmazonEC2FullAccess`
    - `AmazonS3FullAccess`

### AWS CLI

After step (3) in [Terraform steps](#learn-terraform-lambda--api-gateway) use the AWS CLI to confirm contents in s3 bucket.
```bash
aws s3 ls $(terraform output -raw lambda_bucket_name)
```
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