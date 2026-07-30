output "instance_profile_name" {
  description = "IAM Instance Profile name for EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.ec2_role.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.ec2_role.arn
}
