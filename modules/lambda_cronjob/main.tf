locals {
  lambda_function_name = format("cron-%s-%s", var.environmentname, var.entity_name)
  lambda_layer_name    = format("cron-%s-%s", var.environmentname, var.entity_name)
  lambda_role          = format("cron-%s-%s", var.environmentname, var.entity_name)
  event_rule_name      = format("cron-%s-%s", var.environmentname, var.entity_name)
}

module "lambda_layer_s3" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = var.create_layer

  layer_name          = local.lambda_layer_name
  compatible_runtimes = [var.lambda_layer_runtime]

  create_package = var.create_package_layer
  s3_existing_package = {
    bucket = var.builds_bucket
    key    = var.lambda_layer_payload
  }
}

module "lambda_function_externally_managed_package" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_layer_runtime

  create_package = var.create_package_function

  s3_existing_package = {
    bucket = var.builds_bucket
    key    = var.lambda_function_payload
  }

  ignore_source_code_hash = true
  timeout                 = var.timeout
  memory_size             = var.memory_size
  layers = [
    module.lambda_layer_s3.lambda_layer_arn,
  ]
  environment_variables = var.lambda_env_vars
}

resource "aws_cloudwatch_event_rule" "rate" {
  name                = local.event_rule_name
  schedule_expression = var.rate_expression
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rate.name
  target_id = local.lambda_function_name
  arn       = module.lambda_function_externally_managed_package.lambda_function_arn
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
