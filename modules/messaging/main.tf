# SQS Queue
resource "aws_sqs_queue" "main" {
  name                      = "${var.project_name}-${var.environment}-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 30

  kms_master_key_id                 = var.kms_key_id
  kms_data_key_reuse_period_seconds = 300

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-queue"
    }
  )
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name = "${var.project_name}-${var.environment}-dlq"

  message_retention_seconds = 1209600 # 14 days

  kms_master_key_id                 = var.kms_key_id
  kms_data_key_reuse_period_seconds = 300

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-dlq"
    }
  )
}

# Redrive Policy for Main Queue
resource "aws_sqs_queue_redrive_policy" "main" {
  queue_url = aws_sqs_queue.main.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

# EventBridge Custom Bus
resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.project_name}-${var.environment}-bus"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-bus"
    }
  )
}

# EventBridge Rule - Order Created
resource "aws_cloudwatch_event_rule" "order_created" {
  name        = "${var.project_name}-${var.environment}-order-created"
  description = "Trigger when order is created"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["${var.project_name}.order"]
    detail-type = ["Order Created"]
  })

  tags = var.tags
}

# EventBridge Rule - Payment Processed
resource "aws_cloudwatch_event_rule" "payment_processed" {
  name        = "${var.project_name}-${var.environment}-payment-processed"
  description = "Trigger when payment is processed"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["${var.project_name}.payment"]
    detail-type = ["Payment Processed"]
  })

  tags = var.tags
}
