terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "eks-platform-tfstate-agustin"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-platform-tfstate-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}