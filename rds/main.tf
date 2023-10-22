terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
 region = var.aws_region
 profile = var.aws_profile
 allowed_account_ids = var.aws_account_id
}

resource "aws_security_group" "default" {
  name        = "rds_security_group"
  description = "RDS security group"
  vpc_id      = var.vpc_id  # Specify your VPC ID

  # Define your security group rules here, allowing traffic to and from your RDS instance
  # For example, you can allow incoming MySQL traffic from your application servers.
}

resource "aws_db_subnet_group" "subnet" {
  name        = "rds_subnet_group"
  description = "RDS subnet group"
  subnet_ids  = var.private_subnet_ids  # Specify your private subnet IDs
}

resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.default.id]  # Specify your security group ID
  db_subnet_group_name = aws_db_subnet_group.subnet.name

}

