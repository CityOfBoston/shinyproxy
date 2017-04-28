provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_eip_association" "shinyproxy_eip_assoc" {
  instance_id = "${aws_instance.shinyproxy.id}"
  public_ip = "${var.shinyproxy_eip}"
}

resource "aws_instance" "shinyproxy" {
  key_name = "${var.key_name}"
  instance_type = "${var.instance_type}"
  ami = "${var.ubuntu_ami_id}"
  vpc_security_group_ids = ["${aws_default_security_group.default.id}","${aws_security_group.shinyproxy.id}"]
  subnet_id = "${element(var.public_subnets, 1)}"
  tags {
    Name = "shinyproxyserver"
    Environment = "${var.environment}"
  }
  associate_public_ip_address = true
  monitoring = true

  provisioner "file" {
    source = "${path.module}/bin/"
    destination = "/tmp/"
    connection {
      user = "ubuntu"
      type = "ssh"
      host = "${self.public_ip}"
      timeout = "5m"
      private_key = "${file(var.ssh_key)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/shinyproxy/bin",
      "mv /tmp/install_shiny_proxy.sh ~/shinyproxy/bin",
      "chmod u+x ~/shinyproxy/bin/install_shiny_proxy.sh",
      "./shinyproxy/bin/install_shiny_proxy.sh"
    ]
    connection {
      user = "ubuntu"
      type = "ssh"
      host = "${self.public_ip}"
      timeout = "5m"
      private_key = "${file(var.ssh_key)}"
    }
  }
  provisioner "file" {
    source = "${var.shiny_proxy_config_file}"
    destination = "~/shinyproxy/application.yml"
    connection {
      user = "ubuntu"
      type = "ssh"
      host = "${self.public_ip}"
      timeout = "5m"
      private_key = "${file(var.ssh_key)}"
    }
  }

}



data "aws_vpc" "aws_vpc" {
  id = "${var.vpc_id}"
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
  vpc_id = "${var.vpc_id}"
  #Allows access from the web to this instance
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
    self = true
  }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "shiny_proxy_public_ip" {
  value = "${aws_instance.shinyproxy.public_ip}"
}