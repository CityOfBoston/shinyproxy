variable "aws_region" {

}

variable "environment" {

}

variable "vpc_id" {

}

variable "instance_type" {
  default = "m4.large"
}


variable "ssh_key" {
  description = "Your private key file"
}

variable "ubuntu_ami_id" {

}


variable "key_name" {

}


variable "shiny_proxy_config_file" {

}


variable "vpc_cidr" {
  type = "string"
}


variable "azs" {
  type = "list"
  description = "list of availablity zones"
}