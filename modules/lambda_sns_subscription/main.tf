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
  s3_key        = resource.aws_s3_bucket_object.function.key
  function_name = local.resource_name
  role          = aws_iam_role.instance.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout     = var.timeout
  memory_size = var.memory_size
  lifecycle {
    ignore_changes = [
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


resource "aws_s3_bucket_object" "function" {
  bucket = var.builds_bucket
  key    = "dummy_lambda_function_payload.zip"
  source = data.archive_file.function.output_path
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

resource "aws_cloudwatch_log_group" "log_lambda" {
  name              = "/aws/lambda/${local.resource_name}"
  retention_in_days = var.cloudwatch_retention_days
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
