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

data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster.eks.token
}

locals {
  cluster_name = "temzy-cluster"
  ecr_repository_name = "your-ecr-repo-name"  # Replace with your ECR repository name
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.10.0"
  cluster_version = "1.26"
  cluster_name    = local.cluster_name
  vpc_id          = var.vpc_id
  subnets         = var.private_subnets
  manage_aws_auth = true

  node_groups = {
    node-group-1 = {
      name                   = "cluster-node"
      desired_capacity       = 1
      max_capacity           = 5
      min_capacity           = 1
      instance_types         = ["m6in.large"]
      capacity_type          = "ON_DEMAND"
      create_launch_template = true
      additional_tags = {
        "Environment"                                     = "dev"
        "Terraform"                                       = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled "              = "true"
      }
    }
  }
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name      = local.cluster_name
  addon_name        = "kube-proxy"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name      = local.cluster_name
  addon_name        = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = local.cluster_name
  addon_name        = "coredns"
}

resource "aws_iam_policy" "eks_node_ecr_policy" {
  name        = "eks-node-ecr-policy"
  description = "Allows EKS nodes to pull images from the specified ECR repository"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetManifest",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
        ],
        Effect = "Allow",
        Resource = "arn:aws:ecr:us-east-1:326355388919:repository/temzy-ecr"  # Use the ARN of your ECR repository
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_node_ecr_attachment" {
  policy_arn = aws_iam_policy.eks_node_ecr_policy.arn
  role       = module.eks.worker_groups["node-group-1"].eks_worker_node_group_node_role_name
}

resource "aws_ecr_repository" "ecr_repo" {
  name = local.ecr_repository_name
}

# Kubernetes Secret for ECR Registry Credentials
resource "kubernetes_secret" "ecr_credentials" {
  metadata  {
    name = "ecr-credentials"
  }

  data = {
     dockercfg = base64encode(jsonencode({
      "https://<account_id>.dkr.ecr.<region>.amazonaws.com" = {
        username = "AWS", #Replace account username
        password = "your-ecr-access-key",  # Replace with your ECR access key
        email = "none"
        auth = "your-ecr-secret-key"  # Replace with your ECR secret key
      }
    }))
  }
}

# Kubernetes Secret - Deploy it to your EKS Cluster
resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name = "ecr-credentials"
    namespace = "default" # Replace with your desired namespace
  }
  data = kubernetes_secret.ecr_credentials.data
}