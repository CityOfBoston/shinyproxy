variable "aws_region" {
  default = "us-west-2"
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
    bucket = "dev-boston-analytics-terraform-state"
    key = "dev-shiny-proxy-eip"
    region = "us-west-2"
    encrypt = "true"
  }
}
