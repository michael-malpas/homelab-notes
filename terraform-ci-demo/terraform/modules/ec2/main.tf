resource "aws_instance" "instance" {

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  monitoring    = true
  ebs_optimized = true
  key_name      = var.key_name
  user_data     = var.user_data
  vpc_security_group_ids = [
    var.security_group_id
  ]
  subnet_id            = var.subnet_id
  iam_instance_profile = var.iam_instance_profile
  tags = {
    Name = "${var.environment}-${var.server_name}${count.index + 1}"
  }
}
