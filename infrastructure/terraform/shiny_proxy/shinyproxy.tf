provider "aws" {
  region = "${var.aws_region}"
}



//
//resource "aws_instance" "shinyproxy" {
//  key_name = "${var.key_name}"
//  instance_type = "${var.instance_type}"
//  ami = "${var.ubuntu_ami_id}"
//  vpc_security_group_ids = ["${aws_default_security_group.default.id}", "${aws_security_group.shinyproxy.id}","${data.aws_security_group.bastion_sg.id}","${aws_security_group.alb.id}"]
//  iam_instance_profile = "${aws_iam_instance_profile.shiny_profile.id}"
//  subnet_id = "${element(data.aws_subnet.private.*.id, 1)}"
//  tags {
//    Name = "shinyproxyserver"
//    Environment = "${var.environment}"
//  }
//  monitoring = true
//  root_block_device {
//    volume_size = 100
//  }
//
//  provisioner "file" {
//    source = "${path.module}/bin/"
//    destination = "/tmp/"
//    connection {
//      type = "ssh"
//      bastion_user = "ubuntu"
//      bastion_host = "${data.aws_instance.bastion.public_ip}"
//      bastion_private_key = "${file(var.ssh_key)}"
//      bastion_port = 22
//      agent = false
//      user = "ubuntu"
//      host = "${self.private_ip}"
//      private_key = "${file(var.ssh_key)}"
//      timeout = "5m"
//    }
//  }
//  provisioner "file" {
//    source = "${var.shiny_proxy_config_file}"
//    destination = "/tmp/application.yml"
//    connection {
//      type = "ssh"
//      bastion_user = "ubuntu"
//      bastion_host = "${data.aws_instance.bastion.public_ip}"
//      bastion_private_key = "${file(var.ssh_key)}"
//      bastion_port = 22
//      agent = false
//      user = "ubuntu"
//      host = "${self.private_ip}"
//      private_key = "${file(var.ssh_key)}"
//      timeout = "5m"
//    }
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "mkdir -p ~/shinyproxy/bin",
//      "mv /tmp/install_shiny_proxy.sh ~/shinyproxy/bin",
//      "mv /tmp/application.yml ~/shinyproxy/application.yml",
//      "chmod u+x ~/shinyproxy/bin/install_shiny_proxy.sh",
//      " ~/shinyproxy/bin/install_shiny_proxy.sh"
//
//    ]
//    connection {
//      type = "ssh"
//      bastion_user = "ubuntu"
//      bastion_host = "${data.aws_instance.bastion.public_ip}"
//      bastion_private_key = "${file(var.ssh_key)}"
//      bastion_port = 22
//      agent = false
//      user = "ubuntu"
//      host = "${self.private_ip}"
//      private_key = "${file(var.ssh_key)}"
//      timeout = "5m"
//
//    }
//  }
//
//}
//



resource "aws_s3_bucket" "tmp" {
  bucket = "test-shiny-proxy"
  acl = "private"
}

resource "aws_s3_bucket_object" "application_yml" {

  bucket = "${aws_s3_bucket.tmp.id}"
  key = "/apps/${var.environment}/shinyproxy/application.yml"
  source = "${var.application_file}"
}


data "template_file" "user_data" {
  template = "${file("${path.module}/bin/user_data.sh")}"
  vars {
    DOCKER_VERSION="17.06.0~ce-0~ubuntu"
    ecr_repositories = "${var.shiny_app_ecr}"
    SHINY_PROXY_VERSION = "0.9.2"
    BUCKET_NAME = "${aws_s3_bucket.tmp.id}"
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
    value = "shiny-server-ag"
    propagate_at_launch = true
  }
}





