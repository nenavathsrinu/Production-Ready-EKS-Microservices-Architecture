# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = module.alb.alb_zone_id
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS primary endpoint"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "rds_read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = module.rds.rds_read_replica_endpoint
  sensitive   = true
}

# Security Outputs
output "kms_key_id" {
  description = "KMS key ID"
  value       = module.security.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.security.kms_key_arn
}

# Data Outputs
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.data.dynamodb_table_name
}

output "elasticache_endpoint" {
  description = "ElastiCache endpoint"
  value       = module.data.elasticache_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.data.s3_bucket_name
}

# Messaging Outputs
output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = module.messaging.sqs_queue_url
}

output "eventbridge_bus_name" {
  description = "EventBridge bus name"
  value       = module.messaging.eventbridge_bus_name
}

# CI/CD Outputs
output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.cicd.ecr_repository_urls
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = module.cicd.codebuild_project_name
}

