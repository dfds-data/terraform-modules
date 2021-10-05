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
  image_uri     = var.image_uri
  function_name = local.resource_name
  role          = aws_iam_role.instance.arn
  timeout     = var.timeout
  memory_size = var.memory_size
  package_type = "Image"
  environment {
    variables = var.environment_variables
  }
  lifecycle {
    ignore_changes = [
      last_modified,
      qualified_arn,
      version,
      environment,
      timeout,
      memory_size
    ]
  }
}

resource "aws_cloudwatch_log_group" "log_lambda" {
  name              = "/aws/lambda/${local.resource_name}"
  retention_in_days = var.cloudwatch_retention_days
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