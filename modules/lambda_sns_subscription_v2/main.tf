resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
  upper   = false
}

locals {
  resource_name = format("%s-%s", var.entity_name, random_string.random.result)
}


module "lambda_base" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_base"
  entity_name   = local.resource_name
  image_uri = var.image_uri
  environment_variables = var.environment_variables
  timeout     = var.timeout
  memory_size = var.memory_size
  role_policies = var.role_policies
}

resource "aws_sqs_queue" "sqs" {
  name  = module.lambda_base.resource_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = var.message_retention_seconds
  delay_seconds = var.delay_seconds
}

resource "aws_sns_topic_subscription" "subscription" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = var.sns_topic_arn
  endpoint             = aws_sqs_queue.sqs.arn
}


resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.sqs.arn
  enabled          = true
  function_name    = module.lambda_base.lambda_function_arn
  batch_size       = 1
}

resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_base.resource_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.sqs.arn
}

resource "aws_sqs_queue_policy" "subscription" {
  queue_url = aws_sqs_queue.sqs.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.sqs.arn}"
      ],
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${var.sns_topic_arn}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic" "topic" {
  name = local.resource_name
}

module "monitor" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_log_subscription"
  entity_name   = format("mntr-%s", local.resource_name)
  log_group     = module.lambda_base.log_group_name
  image_uri = "469457075771.dkr.ecr.eu-central-1.amazonaws.com/send-message-to-teams:latest"
  environment_variables = {
      webhook_url = "https://dfds.webhook.office.com/webhookb2/099086f9-7359-4d9c-a0f1-d6e48882f42a@73a99466-ad05-4221-9f90-e7142aa2f6c1/IncomingWebhook/bd7eb83cd19440b8b2928ccaecb9d5f2/d7bb3513-a242-4d53-9959-807f4ececf3a"
    }
}