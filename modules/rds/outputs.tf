output "rds_endpoint" {
  description = "RDS primary endpoint"
  value       = aws_db_instance.primary.endpoint
  sensitive   = true
}

output "rds_address" {
  description = "RDS primary address"
  value       = aws_db_instance.primary.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.primary.port
}

output "rds_read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].endpoint : ""
  sensitive   = true
}

output "rds_read_replica_address" {
  description = "RDS read replica address"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].address : ""
  sensitive   = true
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.primary.db_name
}

output "master_username" {
  description = "Master username"
  value       = aws_db_instance.primary.username
  sensitive   = true
}

