variable "cluster_name" {
  description = "The name of the ECS cluster"
}

variable "key_name" {
  description = "The name of the EC2 SSH keypair"
  default     = "tom-dev"
}

variable "instance_type" {
  description = "The instance type"
}

variable "instance_arch" {
  description = "The instance architecture"
}

variable "subnet_ids" {
  description = "The subnets in the default vpc"
  type        = "list"
}
