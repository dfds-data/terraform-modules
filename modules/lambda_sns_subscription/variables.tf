variable "entity_name" {
  description = "Name of the entity"
  type        = string
}

variable "cloudwatch_retention_days" {
  description = "Number of days that cloudwatch will retain logs"
  type        = number
  default = 14
}

variable "filterpattern" {
  description = "Filter pattern"
  type        = string
  default     = "?ERROR ?\"Task timed out\""
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

variable "role_policies" {
  description = "List of policies attached to role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"]
}

variable sns_topic_arn {
  description = "arn of the sns topic"
  type        = string
}

variable "visibility_timeout_seconds" {
  type = number
  default = 720
}

variable "message_retention_seconds" {
  type = number
  default = 60
}

variable "delay_seconds" {
  type = number
  default = 10
  
}

variable "webhook_url" {
  type = string
}

variable "monitor_image_uri" {
  type = string
}