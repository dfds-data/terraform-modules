output "lambda_function_arn" {
  description = "ARN of the lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "lambda_function_name" {
  description = "ARN of the lambda function"
  value       = local.lambda_function_name
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.instance.name
}

output "output_bucket" {
  description = "Name of the output bucket"
  value       = var.output_bucket
}

output "glue_database_name" {
  description = "Name of the AWS Glue database"
  value       = local.glue_database_name
}

output "log_group_name" {
  description = "Name of the AWS Cloudwatch log group"
  value       = aws_cloudwatch_log_group.log_lambda.name
}


output "lambda_builds_bucket" {
  description = "Name s3 bucket for the lambda builds"
  value       = local.lambda_builds_bucket
}