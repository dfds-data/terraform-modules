variable "entity_name" {
  description = "Name of the entity"
  type        = string
}

variable "log_group" {
  description = "Name of the log group"
  type        = string
}

variable "filterpattern" {
  description = "Filter pattern"
  type        = string
  default     = "? ERROR ? WARNING ? Task timed out"
}

variable "role_policies" {
  description = "List of policies attached to role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
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
 
variable "image_uri" {
  description = "Lambda function image uri"
  type        = string
  default     = null
}

variable "environment_variables" {
  type = map(string)
  default = {dummy_var = "dummy_var"}
}