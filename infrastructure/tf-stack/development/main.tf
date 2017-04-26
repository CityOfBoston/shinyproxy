variable "aws_region" {
  default = "us-west-2"
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
  azs = "us-west-2b"
  environment = "development"
  ssh_key = "${var.ssh_key}"
  ssh_key_name = "${var.ssh_key_name}"
  aws_region = "${var.aws_region}"
  shiny_proxy_config_file = "${var.shiny_proxy_config_file}"
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