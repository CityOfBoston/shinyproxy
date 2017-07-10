

provider "aws" {
  region = "${var.aws_region}"
}

variable "aws_region" {
  type = "string"
  default = "us-east-1"
}



variable "shiny_app_docker_images" {
  type = "string"
  description = "A comma seperated string of docker images to download onto the server "
  default = "811289587868.dkr.ecr.us-east-1.amazonaws.com/bfd_response_times,811289587868.dkr.ecr.us-east-1.amazonaws.com/imagine_boston,811289587868.dkr.ecr.us-east-1.amazonaws.com/eviction_analysis"
}

variable "public_application_file" {
  type = "string"
  description = "The shiny proxy application file that contains applications that are to be publically available"
  default = "../../../public_application.yml"
}

variable "private_application_file" {
  type = "string"
  description = "The shiny proxy application file that contains applications that are to be private"
  default = "../../../application.yml"
}

variable "instance_type" {
  type = "string"
  description = "The type of ec2 instance to use in autoscaling groups"
  default = "m4.xlarge"
}


module "shiny_proxy" {
  source = "../../terraform/shiny_proxy"
  environment = "production"
  aws_region = "${var.aws_region}"
  ubuntu_ami_id = "${data.aws_ami.ubuntu_ami.id}"
  vpc_id = "vpc-20f04859"
  key_name = "shinyproxy"
  azs = ["us-east-1b", "us-east-1a", "us-east-1c"]

  shiny_app_ecr = "${var.shiny_app_docker_images}"
  public_application_file = "${var.public_application_file}"
  private_application_file = "${var.private_application_file}"
  autoscaling_max_size = 2
  app_bucket = "city-of-boston"
  instance_type = "${var.instance_type}"
  load_balancer_timeout = 7200
  update_image_frequency = "*/10 * * * *"
}





data "aws_ami" "ubuntu_ami" {
  most_recent      = true
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "name"
    values = ["*hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]


}


terraform {
  required_version = "v0.9.11"
  backend "s3" {
    bucket = "city-of-boston"
    key = "deployments/terraform/shinyproxy/production.tfstate"
    region = "us-east-1"
    encrypt = "true"
  }
}

