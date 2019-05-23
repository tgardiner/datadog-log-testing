output "cluster_id" {
  description = "The id of the ECS cluster"
  value       = "${aws_ecs_cluster.default.id}"
}

output "execution_role_arn" {
  description = "The ARN of the ECS service execution role"
  value       = "${aws_iam_role.execution_role.arn}"
}
