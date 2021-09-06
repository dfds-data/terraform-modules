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
  source_file = "${path.module}/../python_files/cleanup_simple_athena_table.py"
  output_path = "${path.module}/cleanup_simple_athena_table_lambda_function_payload.zip"
}