
resource "aws_alb" "frontend" {
  name = "${var.environment}-shiny-boston"
  internal = false
  subnets = ["${data.aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.alb.id}"]
  idle_timeout = 3600

//  access_logs {
//    bucket = "${var.app_bucket}"
//    prefix = "logs/alb/dev-boston"
//    enabled = true
//  }
  tags {
    Environment = "${var.environment}"
  }

}


resource "aws_alb_listener" "shiny_listener" {
  load_balancer_arn = "${aws_alb.frontend.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.shiny_group.arn}"
    type = "forward"
  }
}





resource  "aws_alb_target_group" "shiny_group" {
  port = 8080
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout = 3
    protocol = "HTTP"
    path = "${var.health_check_path}"
    interval  = 30
  }

}
