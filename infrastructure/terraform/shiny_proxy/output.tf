output "bastion_ip" {
  value = "${data.aws_instance.bastion.public_ip}"
}

output "shiny_private_ip" {
  value = "${aws_instance.shinyproxy.private_ip}"
}

output "alb_public_ip" {
  value = "${aws_alb.frontend.dns_name}"
}


output "shiny_proxy_public_ip" {
  value = "${aws_instance.shinyproxy.public_ip}"
}