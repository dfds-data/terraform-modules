variable "capability_name" {
  description = "Name of the capability to which you deploy the infrastructure"
  type        = string
}

variable "entity_name" {
  description = "Name of the data entity you will create a data pump for"
  type        = string
}

variable "environmentname" {
  description = "Environmentname, i.e. production, staging, etc."
  type        = string
}
variable "log_group" {
  description = "Name of the log group"
  type        = string
}

variable "filterpattern" {
  description = "Filter pattern"
  type        = string
}

variable "lambda_handler" {
  description = "lambda handler"
  type        = string
}

variable "lambda_layer_payload" {
  description = "Zip file containing the lambda layer"
  type        = string
  default     = "lambda_layer_payload_monitoring.zip"
}

variable "webhook_url" {
  description = "Webhook-url"
  type        = string
}


variable "role_policies" {
  description = "List of policies attached to role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}
