resource "aws_instance" "instance" {

  count = var.instance_count

  ami = var.ami_id

  instance_type = var.instance_type

  key_name = var.key_name

  user_data = var.user_data

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name = "${var.environment}-${var.server_name}${count.index + 1}"

    Environment = var.environment

    ManagedBy = "Terraform"

    GitHubDeployed = "True"
  }

}
