locals {
  lambda_function_name         = format("pump-%s-%s", var.environmentname, var.entity_name)
  lambda_role                  = format("pump-%s-%s", var.environmentname, var.entity_name)
  event_rule_name              = format("pump-%s-%s", var.environmentname, var.entity_name)
  athena_query_location_bucket = format("%s-athena-query-location", var.environmentname)
  lambda_output_bucket         = format("%s-output", var.environmentname)
  glue_database_name           = format("%s-db", var.environmentname)
  glue_table_name              = format("%s", var.entity_name)
  lambda_builds_bucket         = format("%s-builds", var.environmentname)
}


resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket           = data.aws_s3_bucket_object.lambda_layer_payload.bucket
  s3_key              = data.aws_s3_bucket_object.lambda_layer_payload.key
  layer_name          = format("%s-layer", var.entity_name)
  compatible_runtimes = ["python3.8"]
  source_code_hash    = data.aws_s3_bucket_object.lambda_layer_payload_hash.body
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket        = data.aws_s3_bucket_object.lambda_function_payload.bucket
  s3_key           = data.aws_s3_bucket_object.lambda_function_payload.key
  function_name    = local.lambda_function_name
  role             = aws_iam_role.instance.arn
  handler          = var.lambda_handler
  runtime          = "python3.8"
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
      glue_database_name   = local.glue_database_name
      glue_table_name      = local.glue_table_name
      lambda_output_bucket = local.lambda_output_bucket
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
