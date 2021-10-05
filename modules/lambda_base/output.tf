output "lambda_function_arn" {
  description = "ARN of the lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.instance.name
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "log_group_name" {
  description = "Name of the AWS Cloudwatch log group"
  value       = aws_cloudwatch_log_group.log_lambda.name
}
