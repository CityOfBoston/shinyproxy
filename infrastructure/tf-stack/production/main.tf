

variable "aws_region" {
  default = "us-east-1"
}

variable "ssh_key" {
  description = "location of ssh key for instance"
}

variable "ssh_key_name" {
  description = "Name of the AWS Keypair"
}


variable "shiny_proxy_config_file" {

}


module "shiny_proxy_stack" {
  source = "../../terraform"
  aws_region = "${var.aws_region}"
  azs = ["us-east-1b"]
  environment = "production"
  ssh_key = "${var.ssh_key}"
  ssh_key_name = "${var.ssh_key_name}"
  shiny_proxy_config_file = "${var.shiny_proxy_config_file}"
}

provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  required_version = "v0.9.3"
  backend "s3" {
    bucket = "boston-analytics-terraform-state"
    key = "prod-shiny-proxy"
    region = "us-east-1"
    encrypt = "true"
  }
}

output "shiny_proxy_ip" {
  value = "${module.shiny_proxy_stack.shiny_proxy_ip}"
}


