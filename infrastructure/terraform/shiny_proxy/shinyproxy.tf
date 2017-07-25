provider "aws" {
  region = "${var.aws_region}"
}





resource "aws_s3_bucket_object" "public_application_yml" {

  bucket = "${var.app_bucket}"
  key = "/apps/${var.environment}/shinyproxy/public_application.yml"
  source = "${var.public_application_file}"
  server_side_encryption = "AES256"
}



resource "aws_s3_bucket_object" "private_application_yml" {

  bucket = "${var.app_bucket}"
  key = "/apps/${var.environment}/shinyproxy/private_application.yml"
  source = "${var.private_application_file}"
  server_side_encryption = "AES256"
}

data "template_file" "public_user_data" {
  template = "${file("${path.module}/bin/user_data.sh")}"
  vars {
    DOCKER_VERSION="17.06.0~ce-0~ubuntu"
    ecr_repositories = "${var.shiny_app_ecr}"
    SHINY_PROXY_VERSION = "0.9.3"
    BUCKET_NAME = "${var.app_bucket}"
    SHINY_APP_CONFIG_FILE = "${aws_s3_bucket_object.public_application_yml.id}"
    AWS_REGION = "${var.aws_region}"
    update_image_frequency = "${var.update_image_frequency}"
    environment = "${var.environment}"
  }

}



data "template_file" "private_user_data" {
  template = "${file("${path.module}/bin/user_data.sh")}"
  vars {
    DOCKER_VERSION="17.06.0~ce-0~ubuntu"
    ecr_repositories = "${var.shiny_app_ecr}"
    SHINY_PROXY_VERSION = "0.9.3"
    BUCKET_NAME = "${var.app_bucket}"
    SHINY_APP_CONFIG_FILE = "${aws_s3_bucket_object.private_application_yml.id}"
    AWS_REGION = "${var.aws_region}"
    update_image_frequency = "${var.update_image_frequency}"
    environment = "${var.environment}"

  }

}

resource "aws_launch_configuration" "public_shiny_lc" {
  name_prefix = "public-shiny-server-"
  image_id = "${var.ubuntu_ami_id}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.shinyproxy.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.shiny_profile.id}"
  key_name = "${var.key_name}"

  user_data = "${data.template_file.public_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

}




resource "aws_launch_configuration" "private_shiny_lc" {
  name_prefix = "private-shiny-server-"
  image_id = "${var.ubuntu_ami_id}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.shinyproxy.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.shiny_profile.id}"
  key_name = "${var.key_name}"

  user_data = "${data.template_file.private_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "private_shiny_asg" {
  name = "private-shiny-asg-${aws_launch_configuration.private_shiny_lc.name}"
  vpc_zone_identifier = ["${data.aws_subnet.private.*.id}"]
  launch_configuration = "${aws_launch_configuration.private_shiny_lc.name}"
  desired_capacity = 1
  max_size = "${var.autoscaling_max_size}"
  min_size = 1
  health_check_type = "EC2"
  health_check_grace_period = "60"
  wait_for_capacity_timeout = 0

  target_group_arns = ["${aws_alb_target_group.private_shiny_tg.id}"]
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
    value = "private-shiny-server-ag-${aws_launch_configuration.private_shiny_lc.count}"
    propagate_at_launch = true
  }
}





resource "aws_autoscaling_group" "public_shiny_asg" {
  name = "public-shiny-asg-${aws_launch_configuration.private_shiny_lc.name}"
  vpc_zone_identifier = ["${data.aws_subnet.private.*.id}"]
  launch_configuration = "${aws_launch_configuration.public_shiny_lc.name}"
  desired_capacity = 1
  max_size = "${var.autoscaling_max_size}"
  min_size = 1
  health_check_type = "EC2"
  health_check_grace_period = "60"
  wait_for_capacity_timeout = 0

  target_group_arns = ["${aws_alb_target_group.public_shiny_tg.id}"]
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
    value = "public-shiny-server-ag-${aws_launch_configuration.public_shiny_lc.count}"
    propagate_at_launch = true
  }
}


