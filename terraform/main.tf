provider "aws" {
  version = "~> 1.51"
  region  = "${var.region}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

module "cluster" {
  source        = "./cluster"
  cluster_name  = "${var.cluster_name}"
  key_name      = "${var.key_name}"
  instance_type = "m4.large"
  instance_arch = "x86_64"
  subnet_ids    = "${data.aws_subnet_ids.default.ids}"
}

module "datadog_agent" {
  source             = "./datadog-agent"
  cluster_id         = "${module.cluster.cluster_id}"
  execution_role_arn = "${module.cluster.execution_role_arn}"
  log_level          = "info"
  DD_API_KEY         = "${var.DD_API_KEY}"
  DD_SITE            = "${var.DD_SITE}"
}

module "http-generator" {
  source             = "./flog"
  cluster_id         = "${module.cluster.cluster_id}"
  execution_role_arn = "${module.cluster.execution_role_arn}"
  service_name       = "http"
  cpu_shares         = "10"
  memory             = "64"
  flog_type          = "apache_common"
  flog_delay         = "0.0025"
  desired_count      = 4
}

module "http-error-generator" {
  source             = "./flog"
  cluster_id         = "${module.cluster.cluster_id}"
  execution_role_arn = "${module.cluster.execution_role_arn}"
  service_name       = "http-error"
  cpu_shares         = "10"
  memory             = "64"
  flog_type          = "apache_error"
  flog_delay         = "0.0025"
  desired_count      = 4
}

module "syslog-generator" {
  source             = "./flog"
  cluster_id         = "${module.cluster.cluster_id}"
  execution_role_arn = "${module.cluster.execution_role_arn}"
  service_name       = "syslog"
  cpu_shares         = "10"
  memory             = "64"
  flog_type          = "rfc3164"
  flog_delay         = "0.0025"
  desired_count      = 4
}
