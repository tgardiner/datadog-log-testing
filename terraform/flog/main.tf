data "template_file" "default" {
  template = "${file("${path.module}/task-definition/flog.json.tpl")}"

  vars {
    service_name = "${var.service_name}"
    cpu_shares   = "${var.cpu_shares}"
    memory       = "${var.memory}"
    flog_type    = "${var.flog_type}"
    flog_delay   = "${var.flog_delay}"
  }
}

resource "aws_ecs_task_definition" "default" {
  family                   = "${var.service_name}"
  container_definitions    = "${data.template_file.default.rendered}"
  execution_role_arn       = "${var.execution_role_arn}"
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "default" {
  name            = "${var.service_name}"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.default.arn}"
  desired_count   = "${var.desired_count}"
}
