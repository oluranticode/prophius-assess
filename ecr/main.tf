terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
 region  = var.aws_region
 profile = var.aws_profile
}

resource "aws_ecr_repository" "my_ecr" {
  name = var.ecr_name
}

resource "aws_ecr_repository_policy" "my_ecr_policy" {
  repository = aws_ecr_repository.my_ecr.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPushPull",
        Effect    = "Allow",
        Principal = "*",
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:GetImage",
          "ecr:GetObject",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:PutImage",
        ],
      },
    ],
  })
}

resource "aws_ecr_lifecycle_policy" "my_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.my_ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description = "Keep last 30 images",
        selection = {
          tagStatus  = "untagged",  # Specify the desired tag status (e.g., "untagged" or "any")
          countType   = "imageCountMoreThan",
          countNumber = 30,
        },
        action = {
          type = "expire",
        },
      },
    ],
  })
}
