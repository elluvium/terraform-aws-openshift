# Endpoint for Internet access

resource "aws_lb" "platform_public" {
  name                             = "${var.platform_name}-public-lb"
  internal                         = false
  subnets                          = ["${var.public_subnet_ids}"]
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  tags = "${map(
    "kubernetes.io/cluster/${var.platform_name}", "owned"
  )}"
}

resource "aws_lb_listener" "platform_public_insecure" {
  load_balancer_arn = "${aws_lb.platform_public.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.platform_public_insecure.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "platform_public_insecure" {
  name                 = "${var.platform_name}-public-insecure"
  port                 = 80
  protocol             = "TCP"
  deregistration_delay = 20
  vpc_id               = "${var.platform_vpc_id}"
}

resource "aws_lb_listener" "platform_public" {
  load_balancer_arn = "${aws_lb.platform_public.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.platform_public.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "platform_public" {
  name                 = "${var.platform_name}-public"
  port                 = 443
  protocol             = "TCP"
  deregistration_delay = 20
  vpc_id               = "${var.platform_vpc_id}"
}

data "dns_a_record_set" "platform_public_lb" {
  host = "${aws_lb.platform_public.dns_name}"
}
