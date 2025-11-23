output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.main.id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.main.arn
}

output "kms_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.main.name
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "elasticache_security_group_id" {
  description = "ElastiCache security group ID"
  value       = aws_security_group.elasticache.id
}

output "rds_password_secret_arn" {
  description = "RDS password secret ARN"
  value       = aws_secretsmanager_secret.rds_password.arn
}

output "eks_node_additional_policy_arn" {
  description = "EKS node additional policy ARN"
  value       = aws_iam_policy.eks_node_additional.arn
}

