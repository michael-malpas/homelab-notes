resource "aws_lb" "alb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false

  security_groups = [
    var.alb_security_group_id
  ]

  tags = {
    Name = "${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
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
    Name = "${var.environment}-alb_tg"
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attach" {
  count = length(var.application_instance_id)

  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = var.application_instance_id[count.index]
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
