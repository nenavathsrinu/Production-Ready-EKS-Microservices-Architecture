output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.main.id
}

output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.main.arn
}

output "sqs_dlq_url" {
  description = "SQS dead letter queue URL"
  value       = aws_sqs_queue.dlq.id
}

output "sqs_dlq_arn" {
  description = "SQS dead letter queue ARN"
  value       = aws_sqs_queue.dlq.arn
}

output "eventbridge_bus_name" {
  description = "EventBridge bus name"
  value       = aws_cloudwatch_event_bus.main.name
}

output "eventbridge_bus_arn" {
  description = "EventBridge bus ARN"
  value       = aws_cloudwatch_event_bus.main.arn
}

output "order_created_rule_arn" {
  description = "Order created rule ARN"
  value       = aws_cloudwatch_event_rule.order_created.arn
}

output "payment_processed_rule_arn" {
  description = "Payment processed rule ARN"
  value       = aws_cloudwatch_event_rule.payment_processed.arn
}

