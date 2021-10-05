module "lambda_base" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_base"
  entity_name   = var.entity_name
  image_uri = var.image_uri
  environment_variables = var.environment_variables
  timeout     = var.timeout
  memory_size = var.memory_size
  role_policies = var.role_policies
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
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_log_subscription_v2"
  entity_name   = format("mntr-%s", var.entity_name)
  log_group     = module.lambda_base.log_group_name
  image_uri = "469457075771.dkr.ecr.eu-central-1.amazonaws.com/send-message-to-teams:latest"

  environment_variables = {
      webhook_url = "https://dfds.webhook.office.com/webhookb2/099086f9-7359-4d9c-a0f1-d6e48882f42a@73a99466-ad05-4221-9f90-e7142aa2f6c1/IncomingWebhook/bd7eb83cd19440b8b2928ccaecb9d5f2/d7bb3513-a242-4d53-9959-807f4ececf3a"
    }
}