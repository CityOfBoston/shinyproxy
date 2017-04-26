
provider "aws" {
    region = "${var.aws_region}"

}


terraform {
  required_version = "v0.9.3"
  backend "s3" {
    bucket = "boston-analytics-terraform-state"
    key = "dev-stack"
    region = "us-east-1"
    encrypt = "true"

  }
}


module "aws_vpc" {
  source = "../../../boston_analytics_tf_modules/vpc"
  name = "shiny-proxy-dev-vpc"

  cidr = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24"]
  public_subnets = ["10.0.101.0/24"]

  enable_dns_hostnames = "true"

  enable_dns_support = "true"

  enable_nat_gateway = "true"

  azs = ["${var.azs}"]

  tags {
    "Terraform" = "true"
    "Environment" = "${var.environment}"
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




module "shinyproxy" {
  source = "../../../boston_analytics_tf_modules/shiny_proxy/"
  vpc_id = "${module.aws_vpc.vpc_id}"
  private_subnets = "${module.aws_vpc.private_subnets}"
  public_subnets = "${module.aws_vpc.public_subnets}"
  instance_type = "m4.large"
  environment = "development"
  #azs = ["${var.azs}"]
  ssh_key = "${var.ssh_key}"
  ubuntu_ami_id = "${module.ubuntu_ami.ami_id}"

  shiny_proxy_config_file = "shinyproxy_application.yaml"
  aws_region = "${var.aws_region}"
  key_name = "anaconda-enterprise.prod"


}






variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "azs" {
  description = "AWS Region Availablity Zones"
  default = ["us-west-2b"]
}

variable "ssh_key" {
  description = "Your private key file"
  default = "/Users/luissano/.ssh/anaconda-enterpriseprod.pem"
}

variable "environment" {
  default = "development"
}



