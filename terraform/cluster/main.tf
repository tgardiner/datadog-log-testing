resource "aws_ecs_cluster" "default" {
  name = "${var.cluster_name}"
}

data "external" "my_ip_addr" {
  program = ["curl", "-s", "https://api.ipify.org?format=json"]
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-${var.instance_arch}-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_iam_role" "instance_role" {
  name = "${var.cluster_name}-instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "instance_policy" {
  name = "${var.cluster_name}-instance_policy"
  role = "${aws_iam_role.instance_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "default" {
  name = "${var.cluster_name}-instance_profile"
  role = "${aws_iam_role.instance_role.name}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.sh.tpl")}"

  vars {
    cluster_name = "${var.cluster_name}"
  }
}

resource "aws_security_group" "default" {
  name        = "${var.cluster_name}-ssh"
  description = "Allow SSH to ${var.cluster_name}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip_addr.result.ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "default" {
  name_prefix          = "${var.cluster_name}-"
  image_id             = "${data.aws_ami.amazon_linux_ecs.id}"
  key_name             = "${var.key_name}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.default.name}"
  user_data            = "${data.template_file.user_data.rendered}"

  security_groups = ["${aws_security_group.default.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.cluster_name}"
  max_size             = "2"
  min_size             = "1"
  desired_capacity     = "2"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  launch_configuration = "${aws_launch_configuration.default.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}"
      propagate_at_launch = true
    },
  ]
}

resource "aws_iam_role" "execution_role" {
  name = "${var.cluster_name}-execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "execution_policy" {
  name = "${var.cluster_name}-execution_policy"
  role = "${aws_iam_role.execution_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
