provider "aws" {
  region = "us-east-1"
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "web"
  cluster_version = "1.21"
  subnets         = ["subnet-0c0224566e63bf9b5", "subnet-0a48981f36fa2dee4"]
  vpc_id          = "vpc-043038dbef4c9a40e"

  node_groups = {
    example = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t2.micro"
      key_name      = "snir-project"
    }
  }
}

# IAM Role for the EKS cluster
resource "aws_iam_role" "eks_iam_role" {
  name = "eks_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy" "eks_iam_policy" {
  name   = "eks_iam_policy"
  role   = aws_iam_role.eks_iam_role.id
  policy = "iam-policy.json"
}

# Deploy Kubernetes resources from YAML files
resource "kubernetes_manifest" "deploy" {
  for_each = fileset(path.module, "*.yml")

  manifest = yamldecode(file(each.value))
}

# Ingress Nginx Controller
resource "kubernetes_manifest" "nginx_controller" {
  manifest = yamldecode(file("ingress-nginx.yml"))
}

# Route 53 Records
resource "aws_route53_zone" "main" {
  name = "surfsupsnir.com"
}

resource "aws_route53_record" "web1" {
  zone_id = Z02699943I5DTUSUR4A3X
  name    = "web1.surfsupsnir.com"
  type    = "A"

  alias {
    name                   = module.eks.cluster_endpoint
    zone_id                = module.eks.cluster_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "web2" {
  zone_id = Z02699943I5DTUSUR4A3X
  name    = "web2.surfsupsnir.com"
  type    = "A"

  alias {
    name                   = module.eks.cluster_endpoint
    zone_id                = module.eks.cluster_id
    evaluate_target_health = true
  }
}

# Ingress Resource from file
resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(file("ingress.yml"))
}
