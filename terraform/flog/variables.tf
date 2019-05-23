variable "cluster_id" {
  description = "The id of the ECS cluster"
}

variable "execution_role_arn" {
  description = "The arn of the ECS service execution role"
}

variable "service_name" {
  description = "The name of the ECS Service"
}

variable "cpu_shares" {
  description = "The number of CPU shares to reserve for the container"
}

variable "memory" {
  description = "The hard limit (in MiB) of memory to present to the container"
}

variable "flog_type" {
  description = "One of apache_common, apache_combined, apache_error, rfc3164"
}

variable "flog_delay" {
  description = "The delay in generation between log lines (in seconds)"
}

variable "desired_count" {
  description = "The number of ECS tasks(containers) to run"
}
