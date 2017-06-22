
provider "aws" {
    region = "${var.aws_region}"

}


//
//module "aws_vpc" {
//  source = "git@github.com:CityOfBoston/boston_analytics_tf_modules.git//vpc?ref=v0.0.4.2"
//  name = "shiny-proxy-vpc"
//
//  cidr = "10.0.0.0/16"
//  private_subnets = ["10.0.1.0/24"]
//  public_subnets = ["10.0.101.0/24"]
//
//  enable_dns_hostnames = "true"
//
//  enable_dns_support = "true"
//
//  enable_nat_gateway = "true"
//
//  azs = ["${var.azs}"]
//
//  tags {
//    "Terraform" = "true"
//    "Environment" = "${var.environment}"
//  }
//
//}
//

module "ubuntu_ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami"
  region = "${var.aws_region}"
  distribution = "xenial"
  architecture = "amd64"
  virttype = "hvm"
  storagetype = "ebs-ssd"
}





module "shinyproxy" {
  source = "shiny_proxy/"
  vpc_id = "${var.vpc_id}"
  private_subnets = "${module.aws_vpc.private_subnets}"
  public_subnets = "${module.aws_vpc.public_subnets}"
  instance_type = "${var.aws_instance_type}"
  environment = "${var.environment}"
  ssh_key = "${var.ssh_key}"
  ubuntu_ami_id = "${module.ubuntu_ami.ami_id}"
  shiny_proxy_config_file = "${var.shiny_proxy_config_file}"
  aws_region = "${var.aws_region}"
  key_name = "${var.ssh_key_name}"
  shinyproxy_eip = "${var.shinyproxy_eip}"


}



variable "vpc_id" {
  description = "the vpc id where you would like to launch instance"
  type = "string"
}

variable "aws_instance_type" {
  default = "m4.large"
}

variable "shiny_proxy_config_file" {
  description = "yaml configuration file for shinyproxy"
}

variable "aws_region" {
  description = "AWS region to launch servers."

}

variable "azs" {
  description = "AWS Region Availablity Zones"

}



variable "ssh_key" {
  description = "Your private key file"

}

variable "ssh_key_name" {
  description = "the name of the private key"
}
variable "environment" {
  #default = "development"
}

variable "shinyproxy_eip" {

}

output "shiny_proxy_ip" {
  value = "${var.shinyproxy_eip}"
}
