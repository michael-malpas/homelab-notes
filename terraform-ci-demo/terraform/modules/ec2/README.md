example configuration used in root main.tf for this module
```
module "web" {
  source = "./modules/ec2"

  # Pass required variables here
  instance_count    = var.instance_count
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  key_name          = var.key_name
  user_data         = file("${path.module}/userdata.sh")
  security_group_id = aws_security_group.web.id
  server_name       = var.server_name
  environment       = var.environment
}
```
