variable "aws_region" {

}

variable "environment" {

}

variable "vpc_id" {

}

variable "instance_type" {
  default = "m4.large"
}


variable "private_subnet_id" {
  description = "public subnet id to launch the instance in"
  type = "list"
}

variable "ssh_key" {
  description = "Your private key file"
}

variable "ubuntu_ami_id" {

}


variable "shinyproxy_eip" {

}


variable "key_name" {

}


variable "shiny_proxy_config_file" {

}

variable "alb_arn" {
  type = "string"
}
