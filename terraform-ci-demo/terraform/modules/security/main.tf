resource "aws_security_group" "bastion" {
  #checkov:skip=CKV_AWS_382: Default AWS outbound access; egress hardening will be implemented later
  #checkov:skip=CKV2_AWS_5: Security group is attached to EC2 instances through the public_server module

  name        = "${var.environment}-bastion-sg"
  description = "Bastion Security Group"

  vpc_id = var.vpc_id

  ingress {
    description = "SSH access from admin IP"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "Outbound allow all traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-bastion-sg"
  }
}

resource "aws_security_group" "alb" {
  #checkov:skip=CKV_AWS_260: Public ALB intentionally serves HTTP traffic
  #checkov:skip=CKV_AWS_382: Default AWS outbound access; egress hardening will be implemented later
  #checkov:skip=CKV2_AWS_5: Security group will be attached to alb in the future

  name        = "${var.environment}-alb-sg"
  description = "Load Balancer Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Inbound http traffic"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Inbound https traffic"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound all traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

resource "aws_security_group" "application" {
  #checkov:skip=CKV_AWS_382: Default AWS outbound access; egress hardening will be implemented later
  #checkov:skip=CKV2_AWS_5: Security group is attached to EC2 instances through the private_server module

  name        = "${var.environment}-application-sg"
  description = "Application Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from load balancer"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  egress {
    description = "Allow all outbound traffic"

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-application-sg"
  }
}
