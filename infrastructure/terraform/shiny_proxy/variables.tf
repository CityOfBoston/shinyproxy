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

variable "application_file" {

}


variable "shiny_app_ecr" {
  type = "string"
  description = "Shiny App Docker Images to pull from ECR Repository"
}

variable "azs" {
  type = "list"
  description = "list of availablity zones"
}


variable "autoscaling_max_size" {
  description = "the max number of instances in this auto scaling group"
}
variable "log_bucket" {
  default = "test-shiny-proxy"
}