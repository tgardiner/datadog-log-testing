variable "cluster_id" {
  description = "The id of the ECS cluster"
}

variable "execution_role_arn" {
  description = "The arn of the ECS service execution role"
}

variable "log_level" {
  description = "The Datadog log level"
}

variable "DD_API_KEY" {
  description = "The datadog api key"
}

variable "DD_SITE" {
  description = "The datadog site url"
}
