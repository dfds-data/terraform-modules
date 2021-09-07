resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
  upper   = false
}

locals {
  resource_name = format("%s-mntr-%s", var.entity_name, random_string.random.result)
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket     = var.builds_bucket
  s3_key        = resource.aws_s3_bucket_object.function.key
  function_name = local.resource_name
  role          = aws_iam_role.instance.arn
  handler       = "monitor_log.lambda_handler"
  runtime       = var.lambda_runtime
  timeout     = var.timeout
  memory_size = var.memory_size
  lifecycle {
    ignore_changes = [
      last_modified,
      qualified_arn,
      version,
      layers
    ]
    ]
  }
}

resource "aws_iam_role" "instance" {
  name               = local.resource_name
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each   = toset(var.role_policies)
  role       = aws_iam_role.instance.name
  policy_arn = each.value
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = local.resource_name
  principal     = "logs.amazonaws.com"
}


resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = local.resource_name
  log_group_name  = var.log_group
  filter_pattern  = var.filterpattern
  destination_arn = aws_lambda_function.lambda_function.arn
  lifecycle {
    ignore_changes = [
      filter_pattern,
    ]
  }
}
resource "aws_s3_bucket_object" "function" {
  bucket = var.builds_bucket
  key    = "monitor_log_lambda_function_payload.zip"
  source = data.archive_file.function.output_path
}
