# # VPC VARIABLES
variable "vpc_name" {
  description = "vpc name"
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  description = "Name of region"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}
variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list
}
variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
}
variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
}
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type    = bool
  default = true
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


# ---------------------------------
# variable "access_key" {
#   type = string
# }

# variable "secret_key" {
#   type = string
# }

# variable "token" {
#   type = string
# }

# variable "region" {
#   type = string
# }