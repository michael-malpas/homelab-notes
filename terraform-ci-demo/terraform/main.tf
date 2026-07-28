terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
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

  #checkov:skip=CKV_AWS_382:EC2 instances require outbound internet access for package updates
  #checkov:skip=CKV_AWS_260:Public HTTP access required for web server demo


  name        = "${var.environment}-web-sg"
  description = "ec2 web server rules"

  vpc_id = module.network.vpc_id

  ingress {
    description = "SSH access from admin IP"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    description = "HTTP web traffic"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound internet access"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-web-sg"
    }
  )
}

module "network" {
  source = "./modules/network"

  common_tags         = local.common_tags
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}

module "web" {
  source = "./modules/ec2"

  common_tags = local.common_tags

  # Pass required variables here
  instance_count    = var.instance_count
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  key_name          = var.key_name
  user_data         = file("${path.module}/userdata.sh")
  security_group_id = aws_security_group.web.id
  server_name       = var.server_name
  environment       = var.environment
  public_subnet_id  = module.network.public_subnet_id
}

resource "local_file" "ansible_inventory" {

  filename = "../ansible/inventory.ini"

  content = templatefile(
    "${path.module}/inventory.tpl",
    {
      public_ips = sort(module.web.public_ips)
    }
  )
}
