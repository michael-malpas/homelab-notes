output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "application_security_group_id" {
  value = aws_security_group.application.id
}
