provider "aws" {
  region = "us-east-1"

}

// Set the IAM User policy for the user that invokes the terraform apply command
resource "aws_iam_user_policy_attachment" "aws_terraform_lambda_policy" {
  user       = "aws-terraform"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_user_policy_attachment" "aws_terraform_cloudwatch_policy" {
  user       = "aws-terraform"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_user_policy_attachment" "aws_terraform_apigateway_policy" {
  user       = "aws-terraform"
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}