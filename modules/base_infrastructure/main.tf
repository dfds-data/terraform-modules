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