variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "application_instance_id" {
  type = list(string)
}

variable "environment" {
  type = string
}
