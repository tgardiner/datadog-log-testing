variable "region" {
  description = "The AWS region"
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
}

variable "key_name" {
  description = "The name of the EC2 SSH keypair"
}

variable "DD_API_KEY" {
  description = "The datadog api key"
}

variable "DD_SITE" {
  description = "The datadog site url"
  default     = "datadoghq.com"
}
