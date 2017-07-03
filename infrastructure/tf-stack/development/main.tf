variable "aws_region" {
  type = "string"
  default = "us-west-2"
}

variable "ssh_key" {
  description = "location of ssh key for instance"
  type = "string"
  default = "~/.ssh/shinyproxy.pem"
}

variable "ssh_key_name" {
  description = "Name of the AWS Keypair"
  type = "string"
  default = "shinyproxy"
}

variable "shiny_proxy_config_file" {
  type = "string"
  default ="../../../public_application.yml"
}

variable "vpc_id" {
  type = "string"
  default = "vpc-ebaf588d"
}

variable "environment" {
  type = "string"
  default = "development"
}

variable "azs" {
  description = "AWS Region Availablity Zones"
  type = "list"
  default = ["us-west-2b","us-west-2a","us-west-2c"]
}

variable "alb_arn" {
  type = "string"
  default = "arn:aws:elasticloadbalancing:us-west-2:811289587868:loadbalancer/app/dev-boston/98b7ff3b78ab45ff"
}


module "shiny_proxy" {
  source = "../../terraform/shiny_proxy"
  shiny_proxy_config_file = "${var.shiny_proxy_config_file}"
  vpc_id = "${var.vpc_id}"
  environment = "${var.environment}"
  aws_region = "${var.aws_region}"
  ssh_key = "${var.ssh_key}"
  ubuntu_ami_id = "${module.ubuntu_ami.ami_id}"#"${data.aws_ami.ubuntu_ami.id}"

  key_name = "${var.ssh_key_name}"
  vpc_cidr = "${data.aws_vpc.dev_vpc.cidr_block}"
  azs = ["${var.azs}"]

  shiny_app_ecr = "811289587868.dkr.ecr.us-west-2.amazonaws.com/bfd_response_times,811289587868.dkr.ecr.us-west-2.amazonaws.com/imagine_boston"
  application_file = "${var.shiny_proxy_config_file}"
  health_check_path = "/"
  autoscaling_max_size = 2
}



data "aws_vpc" "dev_vpc" {
  id = "${var.vpc_id}"
}




module "ubuntu_ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami"
  region = "${var.aws_region}"
  distribution = "xenial"
  architecture = "amd64"
  virttype = "hvm"
  storagetype = "ebs-ssd"
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
    values = ["*hvm-ssd/ubuntu-xenial*"]
  }

  owners = ["099720109477"]


}


variable "shinyproxy_eip" {
  default = "34.208.232.53"
}

provider "aws" {
  region = "${var.aws_region}"
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

output "bastion_public_ip" {
  value = "${module.shiny_proxy.bastion_ip}"
}

//output "shiny_proxy_private_ip" {
//  value = "${module.shiny_proxy.shiny_private_ip}"
//}
