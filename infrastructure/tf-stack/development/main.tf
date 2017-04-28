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

module "shiny_proxy_stack" {
  source = "../../terraform"
  azs = "us-west-2b"
  environment = "development"
  ssh_key = "${var.ssh_key}"
  ssh_key_name = "${var.ssh_key_name}"
  aws_region = "${var.aws_region}"
  shiny_proxy_config_file = "${var.shiny_proxy_config_file}"
  shinyproxy_eip = "${var.shinyproxy_eip}"
  aws_instance_type = "m4.large"
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
  value = "${module.shiny_proxy_stack.shiny_proxy_ip}"
}
