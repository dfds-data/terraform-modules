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
  principal     = "logs.amazonaws.com"
}


resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = module.lambda_base.resource_name
  log_group_name  = var.log_group
  filter_pattern  = var.filterpattern
  destination_arn = module.lambda_base.lambda_function_arn
  lifecycle {
    ignore_changes = [
      filter_pattern,
    ]
  }
}