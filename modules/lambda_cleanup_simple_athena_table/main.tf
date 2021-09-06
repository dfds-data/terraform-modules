locals {
  lambda_function_name = format("%s-cleanup-%s", var.entity_name, var.environmentname)
  lambda_layer_name    = format("%s-cleanup-%s", var.entity_name, var.environmentname)
  lambda_role          = format("%s-cleanup-%s", var.entity_name, var.environmentname)
  event_rule_name      = format("%s-cleanup-%s", var.entity_name, var.environmentname)
}


resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket           = "arn:aws:s3:::aws-data-wrangler-public-artifacts"
  s3_key              = "releases/2.11.0/awswrangler-layer-2.11.0-py3.8.zip"
  layer_name          = "aws-data-wrangler"
  compatible_runtimes = [var.lambda_runtime]
  lifecycle {
    ignore_changes = [
      version
    ]
  }
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket     = var.builds_bucket
  s3_key        = resource.aws_s3_bucket_object.function.key
  function_name = local.lambda_function_name
  role          = aws_iam_role.instance.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  layers = [
    aws_lambda_layer_version.lambda_layer.arn,
  ]
  timeout     = var.timeout
  memory_size = var.memory_size
  lifecycle {
    ignore_changes = [
      last_modified,
      qualified_arn,
      version,
      handler,
      environment
    ]
  }
}


resource "aws_cloudwatch_event_rule" "rate" {
  name                = local.event_rule_name
  schedule_expression = var.rate_expression
  lifecycle {
    ignore_changes = [
      schedule_expression
    ]
  }
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rate.name
  target_id = local.lambda_function_name
  arn       = aws_lambda_function.lambda_function.arn
}

resource "aws_iam_role" "instance" {
  name               = local.lambda_role
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
  function_name = local.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rate.arn
}


resource "aws_cloudwatch_log_group" "log_lambda" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.cloudwatch_retention_days
}

resource "aws_s3_bucket_object" "function" {
  bucket = var.builds_bucket
  key    = "cleanup_simple_athena_table_lambda_function_payload.zip"
  source = data.archive_file.function.output_path
}