data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_s3_bucket_object" "lambda_function_payload_hash" {
  bucket = var.lambda_builds_bucket
  key    = format("%s.base64sha256", var.lambda_function_payload)
}

data "aws_s3_bucket_object" "lambda_function_payload" {
  bucket = var.lambda_builds_bucket
  key    = format("%s", var.lambda_function_payload)
}

data "aws_s3_bucket_object" "lambda_layer_payload_hash" {
  bucket = var.lambda_builds_bucket
  key    = format("%s.base64sha256", var.lambda_layer_payload)
}

data "aws_s3_bucket_object" "lambda_layer_payload" {
  bucket = var.lambda_builds_bucket
  key    = format("%s", var.lambda_layer_payload)
}

data archive_file lambda_function_payload {
  type        = "zip"
  source_file = var.lambda_function_payload_source_file
  output_path = "lambda_function_payload.zip"
}
