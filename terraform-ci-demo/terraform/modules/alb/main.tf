resource "aws_lb" "alb" {
  #checkov:skip=CKV_AWS_91:ALB access logging will be enabled after centralized logging S3 bucket is implemented.
  #checkov:skip=CKV_AWS_150:ALB load balancer is a variable that can be altered to protect when the time comes.
  #checkov:skip=CKV2_AWS_28:WAF protection will be implemented during security hardening phase.
  #checkov:skip=CKV2_AWS_20:HTTP to HTTPS redirect requires ACM certificate and HTTPS listener.
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = var.public_subnet_ids

  security_groups = [
    var.alb_security_group_id
  ]

  drop_invalid_header_fields = true

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "alb-tg" {
  #checkov:skip=CKV_AWS_378:Backend HTTPS encryption deferred until application TLS configuration is implemented.
  name     = "${var.environment}-alb-tg"
  port     = 80
  protocol = "HTTP"

  vpc_id = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${var.environment}-alb-tg"
  }
}

resource "aws_lb_target_group_attachment" "alb-tg-attach" {
  count = length(var.application_instance_id)

  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = var.application_instance_id[count.index]
  port             = 80
}

resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_2:HTTPS listener requires ACM certificate configuration.
  #checkov:skip=CKV_AWS_103:TLS policy requires HTTPS listener implementation.
  #checkov:skip=CKV2_AWS_20:HTTP to HTTPS redirect requires ACM certificate and HTTPS listener.
  load_balancer_arn = aws_lb.alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}
