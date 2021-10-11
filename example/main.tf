provider "aws" {
  region = "eu-central-1"
}

#BEFORE PREPROCESS HISTORY
module "preprocess" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_cronjob"
  entity_name   = "preprocess"
  image_uri = var.monitor_image_uri
  monitor_image_uri = var.monitor_image_uri
  webhook_url = var.webhook_url
}

# PREPROCESS
module "predict" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_sns_subscription"
  entity_name   = "predict"
  image_uri = var.monitor_image_uri
  monitor_image_uri = var.monitor_image_uri
  webhook_url = var.webhook_url
  sns_topic_arn = module.preprocess.topic_arn
}