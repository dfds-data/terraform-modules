resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
  upper   = false
}

locals {
  resource_name = format("%s-%s", var.entity_name, random_string.random.result)
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket     = var.builds_bucket
  s3_key        = var.lambda_function_payload_key
  image_uri     = var.image_uri
  function_name = local.resource_name
  role          = aws_iam_role.instance.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout     = var.timeout
  memory_size = var.memory_size
  layers = var.layers
  package_type = var.package_type
  environment {
    variables = var.environment_variables
  }
  lifecycle {
    ignore_changes = [
      s3_key,
      s3_bucket,
      last_modified,
      qualified_arn,
      version,
      handler,
      environment,
      layers,
      timeout,
      memory_size
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
  lifecycle {
    ignore_changes = [
      assume_role_policy
    ]
  }
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each   = toset(var.role_policies)
  role       = aws_iam_role.instance.name
  policy_arn = each.value
  lifecycle {
    ignore_changes = [
      policy_arn
    ]
  }
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
  key    = "lambda_dummy_function_payload.zip"
  source = data.archive_file.function.output_path
}

resource "aws_sns_topic" "topic" {
  name = local.resource_name
}