output "lambda_function_arn" {
  description = "ARN of the lambda function"
  value       = module.lambda_base.lambda_function_arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = module.lambda_base.iam_role_name
}

output "resource_name" {
  description = "Resource name"
  value       = module.lambda_base.resource_name
}

output "log_group_name" {
  description = "Name of the AWS Cloudwatch log group"
  value       = module.lambda_base.log_group_name
}

output "topic_arn" {
  description = "ARN of the AWS SNS topic"
  value       = aws_sns_topic.topic.arn
}