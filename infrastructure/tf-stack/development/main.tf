

provider "aws" {
  region = "${var.aws_region}"
}

variable "aws_region" {
  type = "string"
  default = "us-west-2"
}




module "shiny_proxy" {
  source = "../../terraform/shiny_proxy"
  environment = "development"
  aws_region = "${var.aws_region}"
  ubuntu_ami_id = "${data.aws_ami.ubuntu_ami.id}"
  vpc_id = "vpc-ebaf588d"
  key_name = "shinyproxy"
  azs = ["us-west-2b", "us-west-2a", "us-west-2c"]

  shiny_app_ecr = "811289587868.dkr.ecr.us-west-2.amazonaws.com/bfd_response_times,811289587868.dkr.ecr.us-west-2.amazonaws.com/imagine_boston"
  public_application_file = "../../../public_application.yml"
  private_application_file = "../../../application.yml"
  health_check_path = "/"
  autoscaling_max_size = 2
  app_bucket = "${aws_s3_bucket.tmp.bucket}"
  instance_type = "m4.large"
  load_balancer_timeout = 7200
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
  required_version = "v0.9.6"
  backend "s3" {
    bucket = "city-of-boston"
    key = "deployments/terraform/shinyproxy/development.tfstate"
    region = "us-east-1"
    encrypt = "true"
  }
}

