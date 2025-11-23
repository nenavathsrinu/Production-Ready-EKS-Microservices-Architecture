output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.repository_url }
}

output "ecr_repository_arns" {
  description = "ECR repository ARNs"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.arn }
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.main.name
}

output "codebuild_project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.main.arn
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = var.github_repo != "" ? aws_codepipeline.main[0].name : ""
}

output "codepipeline_arn" {
  description = "CodePipeline ARN"
  value       = var.github_repo != "" ? aws_codepipeline.main[0].arn : ""
}

output "artifacts_bucket_name" {
  description = "CodePipeline artifacts bucket name"
  value       = aws_s3_bucket.artifacts.id
}

