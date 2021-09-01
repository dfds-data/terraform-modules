data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "archive_file" "function" {
  type        = "zip"
  source_file = "${path.module}/../python_files/dummy_function.py"
  output_path = "${path.module}/cronjob_lambda_function_payload.zip"
}

data "archive_file" "layer" {
  type        = "zip"
  source_dir = "${path.module}/../python_files/python"
  output_path = "${path.module}/cronjob_lambda_layer_payload.zip"
  
}
