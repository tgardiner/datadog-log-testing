data "template_file" "default" {
  template = "${file("${path.module}/task-definition/datadog-agent.json.tpl")}"

  vars {
    DD_API_KEY = "${var.DD_API_KEY}"
    DD_SITE    = "${var.DD_SITE}"
    log_level  = "${var.log_level}"
  }
}

resource "aws_ecs_task_definition" "default" {
  family                   = "datadog-agent"
  container_definitions    = "${data.template_file.default.rendered}"
  execution_role_arn       = "${var.execution_role_arn}"
  requires_compatibilities = ["EC2"]

  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "proc"
    host_path = "/proc"
  }

  volume {
    name      = "cgroup"
    host_path = "/sys/fs/cgroup/"
  }

  volume {
    name      = "pointdir"
    host_path = "/opt/datadog-agent/run"
  }
}

resource "aws_ecs_service" "default" {
  name                = "datadog-agent"
  cluster             = "${var.cluster_id}"
  task_definition     = "${aws_ecs_task_definition.default.arn}"
  scheduling_strategy = "DAEMON"
}
