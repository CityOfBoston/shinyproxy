

provider "aws" {
  region = "${var.aws_region}"
}

variable "aws_region" {
  type = "string"
  default = "us-west-2"
}



variable "shiny_app_docker_images" {
  type = "string"
  description = "A comma seperated string of docker images to download onto the server "
  default = "811289587868.dkr.ecr.us-west-2.amazonaws.com/bfd_response_times,811289587868.dkr.ecr.us-west-2.amazonaws.com/imagine_boston"
}

variable "public_application_file" {
  type = "string"
  description = "The shiny proxy application file that contains applications that are to be publically available"
  default = "../../../config/development/public_application.yml"
}

variable "private_application_file" {
  type = "string"
  description = "The shiny proxy application file that contains applications that are to be private"
  default = "../../../config/development/application.yml"
}

variable "instance_type" {
  type = "string"
  description = "The type of ec2 instance to use in autoscaling groups"
  default = "m4.large"
}



module "shiny_proxy" {
  source = "../../terraform/shiny_proxy"
  environment = "development"
  aws_region = "${var.aws_region}"
  ubuntu_ami_id = "${data.aws_ami.ubuntu_ami.id}"
  vpc_id = "vpc-ebaf588d"
  key_name = "shinyproxy"
  azs = ["us-west-2b", "us-west-2a", "us-west-2c"]

  shiny_app_ecr = "${var.shiny_app_docker_images}"
  public_application_file = "${var.public_application_file}"
  private_application_file = "${var.private_application_file}"
  autoscaling_max_size = 2
  app_bucket = "${aws_s3_bucket.tmp.bucket}"
  instance_type = "${var.instance_type}"
  load_balancer_timeout = 7200
  update_image_frequency = "*/10 * * * *"
  certficate_arn = "arn:aws:acm:us-west-2:811289587868:certificate/3079077b-d5d5-46bc-a116-5f855c361d35"
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

resource "aws_s3_bucket" "tmp" {
  bucket = "test-shiny-proxy"
  acl = "private"
}



terraform {
  required_version = "v0.9.11"
  backend "s3" {
    bucket = "city-of-boston"
    key = "deployments/terraform/shinyproxy/development.tfstate"
    region = "us-east-1"
    encrypt = "true"
  }
}

