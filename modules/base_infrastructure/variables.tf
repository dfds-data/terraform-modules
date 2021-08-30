variable "builds_bucket" {
  description = "Name of the s3 bucket to store code"
  type        = string
}

variable "output_bucket" {
  description = "Name of the s3 bucket in which to store data"
  type        = string
}

variable "athena_query_location" {
  description = "Name of the s3 bucket where athena will store the queries"
  type        = string
}

variable "glue_database" {
  description = "Name of the Glue database"
  type        = string
}

variable "lambda_function_payload_source_file" {
  description = "Name of the lambda function source file"
  type        = string
  default     = "lambda_function_payload.py"
}