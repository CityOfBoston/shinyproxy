provider "aws" {
  region = "${var.aws_region}"
}



resource "aws_s3_bucket_object" "application_yml" {

  bucket = "${var.app_bucket}"
  key = "/apps/${var.environment}/shinyproxy/application.yml"
  source = "${var.application_file}"
  etag = "${md5(var.application_file)}"
}


data "template_file" "user_data" {
  template = "${file("${path.module}/bin/user_data.sh")}"
  vars {
    DOCKER_VERSION="17.06.0~ce-0~ubuntu"
    ecr_repositories = "${var.shiny_app_ecr}"
    SHINY_PROXY_VERSION = "0.9.3"
    BUCKET_NAME = "${var.app_bucket}"
    SHINY_APP_CONFIG_FILE = "${aws_s3_bucket_object.application_yml.id}"
    AWS_REGION = "${var.aws_region}"
  }

}

resource "aws_launch_configuration" "autoshiny" {
  name_prefix = "shiny-server-"
  image_id = "${var.ubuntu_ami_id}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.shinyproxy.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.shiny_profile.id}"
  key_name = "${var.key_name}"

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_autoscaling_group" "autoshinygroup" {
  vpc_zone_identifier = ["${data.aws_subnet.private.*.id}"]
  launch_configuration = "${aws_launch_configuration.autoshiny.name}"
  desired_capacity = 1
  max_size = "${var.autoscaling_max_size}"
  min_size = 1
  health_check_type = "EC2"
  health_check_grace_period = "60"
  wait_for_capacity_timeout = 0

  target_group_arns = ["${aws_alb_target_group.shiny_group.id}"]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
  depends_on = ["aws_alb.frontend"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "shiny-server-ag-${aws_launch_configuration.autoshiny.count}"
    propagate_at_launch = true
  }
}





