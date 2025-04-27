# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions

// This file contains the input variable definitions for the Terraform configuration
variable "aws_region" {
  description = "AWS region for all resources."
  type    = string
  default = "us-east-1"
}