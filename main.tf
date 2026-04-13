module "vpc" {
  source = "./modules/vpc"

  project_name         = "eks-platform"
  cluster_name         = "eks-platform-cluster"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = "eks-platform-cluster"
  cluster_version    = "1.32"
  private_subnet_ids = module.vpc.private_subnet_ids
  node_instance_type = "t3.medium"
  node_desired_size  = 2
  node_min_size      = 1
  node_max_size      = 3
}