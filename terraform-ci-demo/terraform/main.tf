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

  default_tags {
    tags = {
      Environment  = var.environment
      Project      = "terraform-ci-demo"
      Owner        = "Michael Malpas"
      ManagedBy    = "Terraform"
      Repository   = "homelab-notes/terraform-ci-demo"
      CostCenter   = "Homelab"
      AutoDeployed = "True"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }
}

module "security" {
  source      = "./modules/security"
  environment = var.environment

  vpc_id = module.network.vpc_id
  my_ip  = var.my_ip
}

module "iam" {
  source      = "./modules/iam"
  environment = var.environment
}

module "alb" {
  source                     = "./modules/alb"
  environment                = var.environment
  public_subnet_ids          = module.network.public_subnet_ids
  vpc_id                     = module.network.vpc_id
  alb_security_group_id      = module.security.alb_security_group_id
  enable_deletion_protection = var.enable_deletion_protection
}

module "network" {
  source = "./modules/network"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "asg" {
  source = "./modules/asg"

  environment                   = var.environment
  server_name                   = var.server_name
  ami_id                        = data.aws_ami.ubuntu.id
  instance_type                 = var.instance_type
  instance_profile_name         = module.iam.instance_profile_name
  application_security_group_id = module.security.application_security_group_id
  private_subnet_ids            = module.network.private_subnet_ids
  target_group_arn              = module.alb.target_group_arn

  min_size     = var.min_size
  desired_size = var.desired_size
  max_size     = var.max_size

  user_data = file("${path.module}/userdata.sh")
}

