data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_s3_bucket_object" "lambda_function_payload" {
  bucket = var.builds_bucket
  key    = format("%s", var.lambda_function_payload)
}


data "aws_s3_bucket_object" "lambda_layer_payload" {
  bucket = var.builds_bucket
  key    = format("%s", var.lambda_layer_payload)
}
