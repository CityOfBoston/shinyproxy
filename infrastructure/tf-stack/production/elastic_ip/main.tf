
variable "aws_region" {
    default = "us-east-1"
}

provider "aws" {
  region = "${var.aws_region}"
}


resource "aws_eip" "shiny_proxy_eip" {
  vpc = true
}


output  "shiny_proxy_eip" {
  value = "${aws_eip.shiny_proxy_eip.public_ip}"
}

terraform {
  required_version = "v0.9.3"
  backend "s3" {
    bucket = "boston-analytics-terraform-state"
    key = "prod-shiny-proxy-eip"
    region = "us-east-1"
    encrypt = "true"
  }
}