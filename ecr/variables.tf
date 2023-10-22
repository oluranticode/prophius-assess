

variable "ecr_name" {
  description = "Name for the ECR repository"
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = list(string)
}

variable "aws_region" {
  description = "Region"
  type = string
}
