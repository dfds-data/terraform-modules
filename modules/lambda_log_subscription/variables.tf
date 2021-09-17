variable "entity_name" {
  description = "Name of the data entity you will create a data pump for"
  type        = string
}

variable "log_group" {
  description = "Name of the log group"
  type        = string
}

variable "filterpattern" {
  description = "Filter pattern"
  type        = string
  default     = "ERROR"
}

variable "builds_bucket" {
  description = "Name s3 bucket for the lambda builds"
  type        = string
  default = null
}


variable "role_policies" {
  description = "List of policies attached to role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

variable "lambda_runtime" {
  description = "Python runtime"
  type        = string
  default     = "python3.8"
}

variable "cloudwatch_retention_days" {
  description = "Number of days that cloudwatch will retain logs"
  type    = number
  default = 14
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 12
}
 
variable "layers" {
  type = list(string)
  default = null
}


variable "lambda_function_payload_key" {
  description = "Lambda function payload key"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "Lambda function image uri"
  type        = string
  default     = null
}

variable "environment_variables" {
  type = map(string)
  default = null
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
  default     = "monitor_log.lambda_handler"
}

variable "package_type" {
  type = string
  default = "Zip"
  
}