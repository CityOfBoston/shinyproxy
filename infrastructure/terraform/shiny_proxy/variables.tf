variable "aws_region" {
  description = "region to deploy resources"

}

variable "environment" {
  description = "tag resources with this environment"

}

variable "instance_type" {
  description = "type of instances to create for the public and private servers"

}


variable "ubuntu_ami_id" {
  description = "AMI id that the instances will use"

}


variable "key_name" {
  description = "SSH Key name registered with AWS. This private key will be required to ssh into the instance"

}

variable "vpc_id" {
  description = "VPC to launch instances into"
  type = "string"

}

variable "load_balancer_timeout" {
  description = "The length of time that you would like idle connections to last o"
}

variable "public_application_file" {
  description = "The application config file containing the shinyproxy config for public applications"

}
variable "private_application_file" {
  description = "The application config file containing the shinyproxy config for private applications. They will be hidded behind a login"

}

variable "shiny_app_ecr" {
  type = "string"
  description = "Shiny App Docker Images to pull from ECR Repository"
}


variable "azs" {
  type = "list"
  description = "list of availablity zones"
}

variable "certficate_arn" {
  description = "The ssl certificate that the ALB should use"
  default = "arn:aws:acm:us-west-2:811289587868:certificate/3079077b-d5d5-46bc-a116-5f855c361d35"
}

variable "update_image_frequency" {
  description = "The frequency for the cron job to pull new images and restart the server"
}

variable "autoscaling_max_size" {
  description = "the max number of instances in this auto scaling group"
}
variable "app_bucket" {
  default = "test-shiny-proxy"
}

variable "use_secure_load_balancer" {
  default = false
  description = "We dont have a ssl cert for our development environment so we need the ablity to create a lb without https"
}
