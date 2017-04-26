variable "aws_region" {
  default = "us-west-2"
}


module "shiny_proxy_stack" {
  source = "../terraform"
  azs = ["us-west-2b"]
  ssh_key = "/Users/luissano/.ssh/anaconda-enterpriseprod.pem"
  environment = "development"

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