data archive_file lambda_function_payload {
  type        = "zip"
  source_file = var.lambda_function_payload_source_file
  output_path = "lambda_function_payload.zip"
}