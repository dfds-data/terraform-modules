data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/monitor_log.py"
  output_path = "${path.module}/monitor_log.zip"
  
}


data "aws_s3_bucket_object" "lambda_layer_payload" {
  bucket = var.builds_bucket
  key    = var.lambda_layer_payload
}
