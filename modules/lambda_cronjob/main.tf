module "lambda_base" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_base"
  entity_name   = var.entity_name
  image_uri = var.image_uri
  environment_variables = var.environment_variables
  timeout     = var.timeout
  memory_size = var.memory_size
  role_policies = var.role_policies
  cloudwatch_retention_days = var.cloudwatch_retention_days
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_base.resource_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rate.arn
}

resource "aws_cloudwatch_event_rule" "rate" {
  name                = module.lambda_base.resource_name
  schedule_expression = var.rate_expression
  lifecycle {
    ignore_changes = [
      schedule_expression
    ]
  }
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rate.name
  target_id = module.lambda_base.resource_name
  arn       = module.lambda_base.lambda_function_arn
}

resource "aws_sns_topic" "topic" {
  name = module.lambda_base.resource_name
}

module "monitor" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_log_subscription"
  entity_name   = format("mntr-%s", var.entity_name)
  log_group     = module.lambda_base.log_group_name
  image_uri = var.monitor_image_uri
  filterpattern = var.filterpattern


  environment_variables = {
      webhook_url = var.webhook_url
    }
}