# Random password for RDS
resource "random_password" "master_password" {
  length  = 16
  special = true
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-subnet-group"
    }
  )
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.identifier}-params"
  family = "postgres15"

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-params"
    }
  )
}

# RDS Primary Instance
resource "aws_db_instance" "primary" {
  identifier = "${var.identifier}-primary"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id           = var.kms_key_id

  db_name  = var.database_name
  username = var.username
  password = var.password != "" ? var.password : random_password.master_password.result

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name

  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  multi_az               = var.multi_az
  publicly_accessible    = false
  skip_final_snapshot   = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true
  performance_insights_retention_period = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-primary"
    }
  )
}

# RDS Read Replica
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier = "${var.identifier}-replica"

  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = var.instance_class

  publicly_accessible = false
  skip_final_snapshot = true

  performance_insights_enabled = true
  performance_insights_retention_period = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-replica"
    }
  )
}
