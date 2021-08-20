locals {
  output_path = format("%s/metrics_lambda_function_payload.zip", var.builds_bucket)
}



resource "aws_s3_bucket" "builds_bucket" {
  bucket_prefix = var.builds_bucket
  acl           = "private"
}

resource "aws_s3_bucket" "athena_query_location" {
  bucket_prefix = var.athena_query_location
  acl           = "private"
  lifecycle_rule {
    id      = "retention_policy"
    enabled = true
    expiration {
      days = 5
    }
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket_prefix = var.output_bucket
  acl           = "private"
  versioning {
    enabled = true
  }
}

resource "aws_glue_catalog_database" "glue_database" {
  name = var.glue_database
}


# Zip the Lamda function on the fly
data "archive_file" "source" {
  type        = "zip"
  source = "git::https://github.com/dfds-data/terraform-modules/modules/base_infrastructure/lambda_function_payload.py"
  output_path = "lambda_functions/metrics_lambda_function_payload.zip"
}
# upload zip to s3 and then update lamda function from s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${aws_s3_bucket.builds_bucket.id}"
  key    = "metrics_lambda_function_payload.zip"
  source = "${data.archive_file.source.output_path}" # its mean it depended on zip
}