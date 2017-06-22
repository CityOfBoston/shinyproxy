variable "aws_region" {
  default = "us-west-2"
}

variable "ssh_key" {
  description = "location of ssh key for instance"
  default = "~/.ssh/shinyproxy.pem"
}

variable "ssh_key_name" {
  description = "Name of the AWS Keypair"
  default = "shinyproxy"
}

variable "shiny_proxy_config_file" {
  default ="../../../application.yml"
}

variable "vpc_id" {
  default = "vpc-ebaf588d"
}

variable "environment" {
  default = "development"
}

variable "azs" {
  description = "AWS Region Availablity Zones"
  default = "us-west-2b"
}


module "shiny_proxy" {
  source = "../../terraform/shiny_proxy"
  shiny_proxy_config_file = "${var.shiny_proxy_config_file}"
  vpc_id = "${var.vpc_id}"
  environment = "${var.environment}"
  aws_region = "${var.aws_region}"
  ssh_key = "${var.ssh_key}"
  ubuntu_ami_id = "${module.ubuntu_ami.ami_id}"
  shinyproxy_eip = "${var.shinyproxy_eip}"
  key_name = "${var.ssh_key_name}"
  azs = "${var.azs}"
  public_subnets = "${data.aws_subnet_ids.public_subnets}"

}



data "aws_vpc" "dev_vpc" {
  id = "${var.vpc_id}"
}


data "aws_subnet_ids" "public_subnets" {
  vpc_id = "${data.dev_vpc.vpc_id}"

  tags {
    "Name" = "${var.environment}-vpc-subnet-public-${element(var.azs, count.index)}"
  }

}

module "ubuntu_ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami"
  region = "${var.aws_region}"
  distribution = "xenial"
  architecture = "amd64"
  virttype = "hvm"
  storagetype = "ebs-ssd"
}



variable "shinyproxy_eip" {
  default = "35.164.125.172"
}

provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  required_version = "v0.9.3"
  backend "s3" {
    bucket = "dev-boston-analytics-terraform-state"
    key = "dev-shiny-proxy"
    region = "us-west-2"
    encrypt = "true"
  }
}

output "shiny_proxy_ip" {
  value = "${module.shiny_proxy.shiny_proxy_public_ip}"
}
