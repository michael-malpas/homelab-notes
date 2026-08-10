aws_region    = "us-east-1"
instance_type = "t3.micro"
server_name   = "app"
environment   = "prod"
vpc_cidr      = "10.1.0.0/16"
public_subnet_cidrs = [
  "10.1.1.0/24",
  "10.1.2.0/24"
]
private_subnet_cidrs = [
  "10.1.10.0/24",
  "10.1.20.0/24"
]
availability_zones = [
  "us-east-1a",
  "us-east-1b"
]
enable_deletion_protection = false
min_size                   = 2
desired_size               = 2
max_size                   = 2
