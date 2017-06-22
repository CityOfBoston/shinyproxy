provider "aws" {
  region = "${var.aws_region}"
}



data "aws_instance" "bastion" {
  filter {
    name = "tag:Name"
    values = ["bastion"]
  }
}


data  "aws_security_group" "bastion_sg" {
  filter {
    name = "tag:Name"
    values = ["bastion"]
  }
}


resource "aws_instance" "shinyproxy" {
  key_name = "${var.key_name}"
  instance_type = "${var.instance_type}"
  ami = "${var.ubuntu_ami_id}"
  vpc_security_group_ids = ["${aws_default_security_group.default.id}", "${aws_security_group.shinyproxy.id}","${data.aws_security_group.bastion_sg.id}"]
  subnet_id = "${element(var.private_subnet_id, 1)}"
  tags {
    Name = "shinyproxyserver"
    Environment = "${var.environment}"
  }
  monitoring = true
  root_block_device {
    volume_size = 100
  }

  provisioner "file" {
    source = "${path.module}/bin/"
    destination = "/tmp/"
    connection {
      user = "ec2-user"
      type = "ssh"
      agent = true
      host = "${data.aws_instance.bastion.public_ip}"
      timeout = "5m"
      private_key = "${file(var.ssh_key)}"
    }
  }
  provisioner "file" {
    source = "${var.shiny_proxy_config_file}"
    destination = "/tmp/application.yml"
    connection {
      user = "ec2-user"
      type = "ssh"
      agent = true
      host = "${data.aws_instance.bastion.public_ip}"
      timeout = "5m"
      private_key = "${file(var.ssh_key)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "ssh -o StrictHostKeyChecking=no ubuntu@${self.private_ip} mkdir -p /home/ubuntu/shinyproxy/bin",
      "scp -o StrictHostKeyChecking=no /tmp/install_shiny_proxy.sh ubuntu@${self.private_ip}:~/shinyproxy/bin",
      "scp -o StrictHostKeyChecking=no /tmp/application.yml ubuntu@${self.private_ip}:~/shinyproxy/application.yml",
      "ssh -o StrictHostKeyChecking=no ubuntu@${self.private_ip} chmod u+x ~/shinyproxy/bin/install_shiny_proxy.sh",
      "ssh -o StrictHostKeyChecking=no ubuntu@${self.private_ip} ~/shinyproxy/bin/install_shiny_proxy.sh"

    ]
    connection {
      bastion_user = "ec2-user"
      type = "ssh"
      bastion_host = "${data.aws_instance.bastion.public_ip}"
      bastion_private_key = "${file(var.ssh_key)}"
      private_key = "${file(var.ssh_key)}"
      bastion_port = 22
      user = "ubuntu"
      timeout = "2m"

    }
  }

}



resource "aws_default_security_group" "default" {
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "shinyproxy" {
  name = "shinyproxy-security-group"
  vpc_id = "${var.vpc_id}"
  #Allows access from the web to this instance
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }


}


data "aws_alb" "front_end" {
  arn = "${var.alb_arn}"
}


resource "aws_alb_listener" "shiny_listener" {
  load_balancer_arn = "${var.alb_arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.shiny_group.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener_rule" "shiny" {
  listener_arn = "${aws_alb_listener.shiny_listener.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.shiny_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/shiny/*"]
  }
}



resource  "aws_alb_target_group" "shiny_group" {
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
}

resource "aws_alb_target_group_attachment" "shiny_server" {
  target_group_arn = "${aws_alb_target_group.shiny_group.arn}"
  target_id = "${aws_instance.shinyproxy.id}"
  port = 8080
}

output "shiny_proxy_public_ip" {
  value = "${aws_instance.shinyproxy.public_ip}"
}