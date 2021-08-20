variable "entity_name" {
  description = "Name of the data entity you will create a data pump for"
  type        = string
}

variable "environmentname" {
  description = "Environmentname, i.e. production, staging, etc."
  type        = string
}

variable "rate_expression" {
  description = "Rate of execution of the lambda function. This should be a rate expression, e.g. rate(15 days) or rate(30 minutes). See more: https://docs.aws.amazon.com/systems-manager/latest/userguide/reference-cron-and-rate-expressions.html"
  type        = string
}

variable "ddp_endpoint" {
  description = "URL of the ddp endpoint"
  type        = string
  default     = "none"
}

variable "lambda_function_payload" {
  description = "Zip file containing the lambda function"
  type        = string
  default     = "lambda_function_payload.zip"

}

variable "lambda_layer_payload" {
  description = "Zip file containing the lambda layer"
  type        = string
  default     = "lambda_layer_payload.zip"
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
}

variable "role_policies" {
  description = "List of policies attached to role"
  type        = list(string)
}

variable "secrets_name" {
  description = "Name of the secret in secrets manager"
  type        = string
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