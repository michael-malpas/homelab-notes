variable "aws_region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "public_server_name" {
  type = string
}

variable "private_server_name" {
  type = string
}

variable "public_instance_count" {
  type = string
}

variable "private_instance_count" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}
