# AWS IAM User Role Setup for Development
Read section below for information to set up main profile to run terraform on AWS. The details below assume that you have admin/root access permission to the aws resources. Otherwise, if you are granted an IAM-User navigate to the AWS console and grant the `IAMFullAccess` policy. This directory assumes the latter, but provides details on the formal. 

## Purpose
Sets up an IAM user role with full IAM access permissions for interactive development and pipeline automation with Terraform. This setup is particularly useful for developers who need to manage AWS resources and IAM permissions through Infrastructure as Code.

## Prerequisites
- AWS account with admin access
- AWS CLI installed and configured
- Basic understanding of AWS IAM concepts
- Terraform installed locally (v0.12 or later)

## Details
This configuration creates:
- IAM user for interactive development
- Attaches IAMFullAccess policy to allow Terraform to manage IAM resources
- Enables programmatic and console access

The IAMFullAccess permission is required because:
- Terraform needs to create and manage IAM roles
- CI/CD pipelines require permission delegation
- Resource policies often need IAM modifications

## Usage of AWS IAM User Role

### Option 1: Using AWS Management Console (Root/Admin User)

1. Log in to the AWS Management Console with root or admin credentials
2. Navigate to IAM service
3. Click "Users" in the left sidebar and then "Create user"
4. Set username as "aws-terraform"
5. Enable "Access key - Programmatic access"
6. On permissions, attach existing policy "IAMFullAccess"
7. Review and create user
8. Save the access key ID and secret access key securely and pass them to the env variables.

### Option 2: Using Terraform with CLI Key Creation (Recommended)

> ⚠️ Important: Terraform state files store resources in plain text. Creating access keys via Terraform resources would expose sensitive credentials in state files. Always create access keys manually through AWS CLI or Console.

Create a Terraform configuration file `main.tf`:

```hcl
provider "aws" {
    region = "us-west-2"  # Set your desired region
}

resource "aws_iam_user" "terraform_user" {
    name = "aws-terraform"
}

resource "aws_iam_user_policy_attachment" "admin_access" {
    user       = aws_iam_user.terraform_user.name
    policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
```

1. Apply the configuration:
```bash
terraform init
terraform apply
```

2. After user creation, generate access keys manually (safer approach):
```bash
# Using AWS CLI with admin credentials
aws iam create-access-key --user-name aws-terraform
```

3. Configure credentials using one of these methods:
```bash
# Environment variables (temporary)
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"

# AWS CLI named profile (persistent)
aws configure --profile aws-terraform
```
