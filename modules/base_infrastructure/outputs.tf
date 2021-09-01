output "builds_bucket" {
  description = "Name of the s3 bucket for the builds"
  value       = aws_s3_bucket.builds_bucket.id
}
output "athena_query_location" {
  description = "Name of the s3 bucket for the Athena queries"
  value       = aws_s3_bucket.athena_query_location.id
}
output "output_bucket" {
  description = "Name of the s3 bucket for the output data"
  value       = aws_s3_bucket.output_bucket.id
}
output "glue_database" {
  description = "Name of glue catalog database"
  value       = aws_glue_catalog_database.glue_database.id
}

 