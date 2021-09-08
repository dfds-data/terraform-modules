resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
  upper   = false
}

locals {
  resource_name = format("%s_%s", var.entity_name, random_string.random.result)
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket     = var.builds_bucket
  s3_key        = resource.aws_s3_bucket_object.function.key
  function_name = local.resource_name
  role          = aws_iam_role.instance.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout     = var.timeout
  memory_size = var.memory_size
  lifecycle {
    ignore_changes = [
      last_modified,
      qualified_arn,
      version,
      handler,
      environment,
      layers
    ]
  }
}


resource "aws_cloudwatch_event_rule" "rate" {
  name                = local.resource_name
  schedule_expression = var.rate_expression
  lifecycle {
    ignore_changes = [
      schedule_expression
    ]
  }
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rate.name
  target_id = local.resource_name
  arn       = aws_lambda_function.lambda_function.arn
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
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rate.arn
}
 

resource "aws_cloudwatch_log_group" "log_lambda" {
  name              = "/aws/lambda/${local.resource_name}"
  retention_in_days = var.cloudwatch_retention_days
}

resource "aws_s3_bucket_object" "function" {
  bucket = var.builds_bucket
  key    = "cronjob_lambda_function_payload.zip"
  source = data.archive_file.function.output_path
}