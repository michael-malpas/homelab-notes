aws_region             = "us-east-1"
instance_type          = "t3.micro"
key_name               = "devops-lab-key"
public_server_name     = "web"
private_server_name    = "app"
public_instance_count  = 1
private_instance_count = 2
environment            = "dev"
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.20.0/24"
]
availability_zones = [
  "us-east-1a",
  "us-east-1b"
]
enable_deletion_protection = false
