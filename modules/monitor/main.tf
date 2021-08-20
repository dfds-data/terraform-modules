locals {
  lambda_function_name = format("mntr-%s-%s", var.environmentname, var.entity_name)
  lambda_role          = format("mntr-%s-%s", var.environmentname, var.entity_name)
  logfilter_name = format("mntr-%s-%s", var.environmentname, var.entity_name)
}

resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket           = data.aws_s3_bucket_object.lambda_layer_payload.bucket
  s3_key              = data.aws_s3_bucket_object.lambda_layer_payload.key
  layer_name          = format("mntr-%s-layer", var.entity_name)
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
  environment {
    variables = {
      webhook_url = var.webhook_url
    }
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
  # source_arn    = aws_cloudwatch_event_rule.rate.arn
}


resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = local.logfilter_name
  log_group_name  = var.log_group
  filter_pattern  = var.filterpattern
  destination_arn = aws_lambda_function.lambda_function.arn
}


