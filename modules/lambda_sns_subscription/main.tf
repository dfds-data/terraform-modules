resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
  upper   = false
}

locals {
  resource_name = format("%s-%s", var.entity_name, random_string.random.result)
}

resource "aws_lambda_function" "lambda_function" {
  s3_bucket     = var.builds_bucket
  s3_key        = var.lambda_function_payload_key
  image_uri     = var.image_uri
  function_name = local.resource_name
  role          = aws_iam_role.instance.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout     = var.timeout
  memory_size = var.memory_size
  layers = var.layers
  package_type = var.package_type
  environment {
    variables = var.environment_variables
  }
  lifecycle {
    ignore_changes = [
      s3_key,
      s3_bucket,
      last_modified,
      qualified_arn,
      version,
      handler,
      environment,
      layers,
      timeout,
      memory_size
    ]
  }
}

resource "aws_iam_role" "instance" {
  name               = local.resource_name
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  lifecycle {
    ignore_changes = [
      assume_role_policy
    ]
  }
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each   = toset(var.role_policies)
  role       = aws_iam_role.instance.name
  policy_arn = each.value
  lifecycle {
    ignore_changes = [
      policy_arn
    ]
  }
}

resource "aws_sns_topic" "topic" {
  name = local.resource_name
}

module "monitor" {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_log_subscription"
  entity_name   = format("mntr-%s", local.resource_name)
  log_group     = aws_cloudwatch_log_group.log_lambda.name
  image_uri = "469457075771.dkr.ecr.eu-central-1.amazonaws.com/send-message-to-teams:latest"
  package_type = "Image"
  lambda_runtime = null
  lambda_handler = null
  lambda_function_payload_key = null

  environment_variables = {
      webhook_url = "https://dfds.webhook.office.com/webhookb2/099086f9-7359-4d9c-a0f1-d6e48882f42a@73a99466-ad05-4221-9f90-e7142aa2f6c1/IncomingWebhook/bd7eb83cd19440b8b2928ccaecb9d5f2/d7bb3513-a242-4d53-9959-807f4ececf3a"
    }
}

resource "aws_cloudwatch_log_group" "log_lambda" {
  name              = "/aws/lambda/${local.resource_name}"
  retention_in_days = var.cloudwatch_retention_days
}


resource "aws_sqs_queue" "sqs" {
  name  = local.resource_name
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
  function_name    = aws_lambda_function.lambda_function.arn
  batch_size       = 1
}

resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = local.resource_name
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
