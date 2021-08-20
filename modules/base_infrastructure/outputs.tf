output "builds_bucket" {
  description = "Name of the s3 bucket for the builds"
  value       = builds_bucket.id
}
output "athena_query_location" {
  description = "Name of the s3 bucket for the Athena queries"
  value       = athena_query_location.id
}
output "output_bucket" {
  description = "Name of the s3 bucket for the output data"
  value       = output_bucket.id
}
output "aws_glue_catalog_database" {
  description = "Name of glue catalog database"
  value       = aws_glue_catalog_database
}
