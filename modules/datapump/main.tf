locals {
  lambda_function_name = format("pump-%s-%s", var.environmentname, var.entity_name)
  lambda_layer_name = format("pump-%s-%s", var.environmentname, var.entity_name)
  lambda_role          = format("pump-%s-%s", var.environmentname, var.entity_name)
  event_rule_name      = format("pump-%s-%s", var.environmentname, var.entity_name)
}

resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket = var.lambda_layer_bucket
  s3_key = var.lambda_layer_key
  layer_name = local.lambda_layer_name
  compatible_runtimes = [var.lambda_layer_runtime]
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket        = data.aws_s3_bucket_object.lambda_function_payload.bucket
  s3_key           = data.aws_s3_bucket_object.lambda_function_payload.key
  function_name    = local.lambda_function_name
  role             = aws_iam_role.instance.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_layer_runtime
  source_code_hash = data.aws_s3_bucket_object.lambda_function_payload_hash.body
  layers = [
    aws_lambda_layer_version.lambda_layer.arn,
  ]
  timeout     = var.timeout
  memory_size = var.memory_size
  environment {
    variables = {
      ddp_endpoint         = var.ddp_endpoint
      secrets_name         = var.secrets_name
      glue_database   = var.glue_database
      glue_table_name      = var.entity_name
      output_bucket        = var.output_bucket
      lambda_output_folder = var.entity_name
      environmentname      = var.environmentname
    }
  }
}

resource "aws_cloudwatch_event_rule" "rate" {
  name                = local.event_rule_name
  schedule_expression = var.rate_expression
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
  retention_in_days = 14
}
