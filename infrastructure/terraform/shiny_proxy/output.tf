output "bastion_ip" {
  value = "${data.aws_instance.bastion.public_ip}"
}


output "alb_dns_name" {
  value = "${aws_alb.frontend.dns_name}"
}


output "rendered_user_data" {
  value = "${data.template_file.user_data.rendered}"
}