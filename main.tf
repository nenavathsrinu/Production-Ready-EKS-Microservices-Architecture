terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "s3" {
    # Configure your S3 backend here
    # bucket = "your-terraform-state-bucket"
    # key    = "eks-microservices/terraform.tfstate"
    # region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones  = var.availability_zones
  environment          = var.environment
  project_name         = var.project_name
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  single_nat_gateway   = false

  tags = var.tags
}

# Security Module
module "security" {
  source = "./modules/security"

  environment  = var.environment
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id

  tags = var.tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_groups = var.eks_node_groups

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = true

  enable_irsa = true
  kms_key_arn = module.security.kms_key_arn

  tags = var.tags

  depends_on = [
    module.vpc,
    module.security
  ]
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  name            = "${var.project_name}-${var.environment}"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnet_ids
  certificate_arn = var.alb_certificate_arn
  domain_name     = var.domain_name

  enable_waf = true

  tags = var.tags

  depends_on = [module.vpc]
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  identifier     = "${var.project_name}-${var.environment}"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.database_subnet_ids
  security_group_ids = [module.security.rds_security_group_id]

  database_name = var.rds_database_name
  username      = var.rds_username
  password      = var.rds_password

  backup_retention_period = 7
  multi_az                = true
  create_read_replica     = true

  kms_key_id = module.security.kms_key_id

  tags = var.tags

  depends_on = [
    module.vpc,
    module.security
  ]
}

# Data Module (DynamoDB, ElastiCache, S3)
module "data" {
  source = "./modules/data"

  environment  = var.environment
  project_name = var.project_name

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.elasticache_security_group_id]

  kms_key_id = module.security.kms_key_id

  tags = var.tags

  depends_on = [module.vpc, module.security]
}

# Messaging Module
module "messaging" {
  source = "./modules/messaging"

  environment  = var.environment
  project_name = var.project_name
  kms_key_id   = module.security.kms_key_id

  tags = var.tags

  depends_on = [module.security]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  environment  = var.environment
  project_name = var.project_name
  cluster_name = module.eks.cluster_id
  kms_key_id   = module.security.kms_key_id

  tags = var.tags

  depends_on = [module.eks, module.security]
}

# CI/CD Module
module "cicd" {
  source = "./modules/cicd"

  environment  = var.environment
  project_name = var.project_name

  github_repo      = var.github_repo
  github_branch    = var.github_branch
  github_token     = var.github_token
  ecr_repositories = var.ecr_repositories

  eks_cluster_name = module.eks.cluster_name
  eks_cluster_arn  = module.eks.cluster_arn

  tags = var.tags

  depends_on = [module.eks]
}

