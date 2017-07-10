variable "aws_region" {

}

variable "environment" {

}

variable "instance_type" {
}


variable "ubuntu_ami_id" {

}


variable "key_name" {

}

variable "vpc_id" {
  type = "string"

}


variable "load_balancer_timeout" {
  description = "The length of time that you would like idle connections to last o"
}

variable "public_application_file" {

}

variable "private_application_file" {

}

variable "health_check_path" {
  description = "the path that the alb will check to monitor health of instance"
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
variable "app_bucket" {
  default = "test-shiny-proxy"
}