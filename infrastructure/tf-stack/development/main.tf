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
  default ="../../../application.yml"
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
  default = ["us-west-2b"]
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
  ubuntu_ami_id = "${module.ubuntu_ami.ami_id}"
  key_name = "${var.ssh_key_name}"
  private_subnet_id = "${data.aws_subnet.private.*.id}"
  alb_arn = "${var.alb_arn}"
  vpc_cidr = "${data.aws_vpc.dev_vpc.cidr_block}"

}



data "aws_vpc" "dev_vpc" {
  id = "${var.vpc_id}"
}




data "aws_subnet" "private" {
  vpc_id = "${var.vpc_id}"
  count = "${length(var.azs)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags {
    Name = "${var.environment}-vpc-subnet-private-${element(var.azs,count.index)}"
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

output "shiny_proxy_private_ip" {
  value = "${module.shiny_proxy.shiny_private_ip}"
}
