output "application_log_group_name" {
  description = "Application log group name"
  value       = aws_cloudwatch_log_group.application.name
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "eks_cpu_alarm_arn" {
  description = "EKS CPU alarm ARN"
  value       = aws_cloudwatch_metric_alarm.eks_cpu_high.arn
}

output "alb_5xx_alarm_arn" {
  description = "ALB 5xx errors alarm ARN"
  value       = aws_cloudwatch_metric_alarm.alb_5xx_errors.arn
}

data "aws_region" "current" {}

