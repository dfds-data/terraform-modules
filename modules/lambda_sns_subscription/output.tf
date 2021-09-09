output "lambda_function_arn" {
  description = "ARN of the lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "lambda_function_name" {
  description = "ARN of the lambda function"
  value       = local.resource_name
}
output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.instance.name
}
