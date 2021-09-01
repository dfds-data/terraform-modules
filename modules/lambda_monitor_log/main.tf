locals {
  lambda_function_name = format("%s-mntr-%s", var.entity_name, var.environmentname)
  lambda_layer_name    = format("%s-mntr-%s", var.entity_name, var.environmentname)
  lambda_role          = format("%s-mntr-%s", var.entity_name, var.environmentname)
   logfilter_name      = format("%s-mntr-%s", var.entity_name, var.environmentname)
}


resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket        = var.builds_bucket
  s3_key           = resource.aws_s3_bucket_object.layer.key
  layer_name          = local.lambda_layer_name
  compatible_runtimes = [var.lambda_runtime]
  lifecycle {
    ignore_changes = [
      "version"
    ]
  }
}


resource "aws_lambda_function" "lambda_function" {
  s3_bucket        = var.builds_bucket
  s3_key           = resource.aws_s3_bucket_object.function.key
  function_name    = local.lambda_function_name
  role             = aws_iam_role.instance.arn
  handler          = "monitor_log.lambda_handler"
  runtime          = var.lambda_runtime
  layers = [
    aws_lambda_layer_version.lambda_layer.arn,
  ]
  timeout = var.timeout
  memory_size = var.memory_size
  lifecycle {
    ignore_changes = [
      "last_modified",
      "qualified_arn",
      "version"
    ]
  }
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
  principal     = "logs.amazonaws.com"
}


resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = local.logfilter_name
  log_group_name  = var.log_group
  filter_pattern  = var.filterpattern
  destination_arn = aws_lambda_function.lambda_function.arn
}

resource "aws_s3_bucket_object" "function" {
  bucket = var.builds_bucket
  key    = "monitor_log_lambda_function_payload.zip"
  source = data.archive_file.function.output_path
}

resource "aws_s3_bucket_object" "object" {
  bucket = var.builds_bucket
  key    = "monitor_log_lambda_function_payload.zip"
  source = data.archive_file.function.output_path
}