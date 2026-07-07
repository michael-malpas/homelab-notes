terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web" {

  name = "day23-web-sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {

  count = var.instance_count

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  key_name = var.key_name

  user_data = file("${path.module}/userdata.sh")

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  tags = {
    Name = "${var.environment}-${var.server_name}${count.index + 1}"

    Environment = var.environment

    ManagedBy = "Terraform"
  }

}

resource "local_file" "ansible_inventory" {

  filename = "../ansible/inventory.ini"

  content = templatefile(
    "${path.module}/inventory.tpl",
    {
      public_ips = aws_instance.web[*].public_ip
    }
  )
}
