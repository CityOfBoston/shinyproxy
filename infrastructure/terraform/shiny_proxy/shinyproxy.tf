provider "aws" {
  region = "${var.aws_region}"
}




resource "aws_instance" "shinyproxy" {
  key_name = "${var.key_name}"
  instance_type = "${var.instance_type}"
  ami = "${var.ubuntu_ami_id}"
  vpc_security_group_ids = ["${aws_default_security_group.default.id}", "${aws_security_group.shinyproxy.id}","${data.aws_security_group.bastion_sg.id}","${aws_security_group.alb.id}"]
  subnet_id = "${element(data.aws_subnet.private.*.id, 1)}"
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
      type = "ssh"
      bastion_user = "ubuntu"
      bastion_host = "${data.aws_instance.bastion.public_ip}"
      bastion_private_key = "${file(var.ssh_key)}"
      bastion_port = 22
      agent = false
      user = "ubuntu"
      host = "${self.private_ip}"
      private_key = "${file(var.ssh_key)}"
      timeout = "5m"
    }
  }
  provisioner "file" {
    source = "${var.shiny_proxy_config_file}"
    destination = "/tmp/application.yml"
    connection {
      type = "ssh"
      bastion_user = "ubuntu"
      bastion_host = "${data.aws_instance.bastion.public_ip}"
      bastion_private_key = "${file(var.ssh_key)}"
      bastion_port = 22
      agent = false
      user = "ubuntu"
      host = "${self.private_ip}"
      private_key = "${file(var.ssh_key)}"
      timeout = "5m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/shinyproxy/bin",
      "mv /tmp/install_shiny_proxy.sh ~/shinyproxy/bin",
      "mv /tmp/application.yml ~/shinyproxy/application.yml",
      "chmod u+x ~/shinyproxy/bin/install_shiny_proxy.sh",
      " ~/shinyproxy/bin/install_shiny_proxy.sh"

    ]
    connection {
      type = "ssh"
      bastion_user = "ubuntu"
      bastion_host = "${data.aws_instance.bastion.public_ip}"
      bastion_private_key = "${file(var.ssh_key)}"
      bastion_port = 22
      agent = false
      user = "ubuntu"
      host = "${self.private_ip}"
      private_key = "${file(var.ssh_key)}"
      timeout = "5m"

    }
  }

}


