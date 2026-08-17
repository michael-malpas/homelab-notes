variable "private_subnet_ids" {
  type = list(string)
}

variable "application_security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "user_data" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "server_name" {
  type = string
}

variable "min_size" {
  type = string
}

variable "desired_size" {
  type = string
}

variable "max_size" {
  type = string
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB"
  type        = number
  default     = 8
}
