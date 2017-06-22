output "bastion_ip" {
  value = "${data.aws_instance.bastion.public_ip}"
}

output "shiny_private_ip" {
  value = "${aws_instance.shinyproxy.private_ip}"
}

output "alb_public_ip" {
  value = "${data.aws_alb.front_end.dns_name}"
}