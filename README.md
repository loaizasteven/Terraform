# Terraform
Infrastructure As Code

## Docker Build
Follows the instructions from [Hashicorp-Terraform](https://developer.hashicorp.com/terraform/tutorials/docker-get-started/docker-build)

## Learn Terraform Lambda + API Gateway
Follow the instructinos from [learn-terraform-lambda-api-gateway](https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway)

> See [Set AWS IAM user policy](./set-aws-iam-user-policy/) first.

After creating the resources, you can invoke the lambda function using AWS CLI commands and the Terraform state outputs.

`aws lambda invoke --region=us-east-1 --function-name=$(terraform output -raw function_name) response.json`