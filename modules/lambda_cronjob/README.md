# How to use

This module has three dependencies. You will need to have created a builds
bucket. You can create that manually or create it with the base_infrastructure
module. You also need to upload a lambda function payload and a lambda layer
payload to the builds bucket. These are zip files defining the lambda function
code and the execution environment.

```
module "cronjob" {
  source                  = "github.com/dfds-data/terraform-modules/modules/lambda_cronjob"
  environmentname         = "prod"
  entity_name             = "metrics"
  rate_expression         = "cron(0 7 1 * ? *)"
  lambda_function_payload = "hello_world_lambda_function_payload.zip"
  lambda_layer_payload    = "awswrangler_lambda_layer_payload.zip"
  lambda_handler          = "metrics.lambda_handler"
  role_policies           = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonAthenaFullAccess", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
  builds_bucket           = module.base_infrastructure.builds_bucket
}

```
