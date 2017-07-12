
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


resource "aws_alb_listener" "public_shiny_listener" {
  load_balancer_arn = "${aws_alb.frontend.arn}"
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.certficate_arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.public_shiny_tg.arn}"
    type = "forward"
  }
}



resource "aws_alb_listener" "private_shiny_listener" {
  load_balancer_arn = "${aws_alb.frontend.arn}"
  port = 3838
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.certficate_arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.private_shiny_tg.arn}"
    type = "forward"
  }
}



resource  "aws_alb_target_group" "private_shiny_tg" {
  name = "private-shiny-tg"
  port = 8080
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"

    stickiness {
      type = "lb_cookie"
      cookie_duration = 86400
      enabled = true
    }

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout = 3
    protocol = "HTTP"
    path = "/login"
    interval  = 30
  }

}




resource  "aws_alb_target_group" "public_shiny_tg" {
  name = "public-shiny-tg"
  port = 8080
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"

     stickiness {
      type = "lb_cookie"
      cookie_duration = 86400
      enabled = true
    }

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout = 3
    protocol = "HTTP"
    path = "/public"
    interval  = 30
  }

}
