variable "db_allocated_storage" {
  description = "The amount of allocated storage for the RDS instance (in GB)."
  type        = number
  
}

variable "db_storage_type" {
  description = "The type of storage (e.g., gp2) for the RDS instance."
  type        = string
  
}

variable "db_instance_class" {
  description = "The RDS instance type (e.g., db.t2.micro)."
  type        = string
  
}

variable "db_name" {
  description = "The name of the MySQL database."
  type        = string
  
}

variable "db_username" {
  description = "The username for the MySQL database."
  type        = string
  # default     = "admin"
}

variable "db_password" {
  description = "The password for the MySQL database."
  type        = string
  # default     = "YourPasswordHere"
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets where the RDS instance will be deployed."
  type        = list(string)

}

variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be created."
  type        = string

}

#----------------------------------------
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
