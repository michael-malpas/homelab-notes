variable "aws_region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "server_name" {
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
  type    = number
  default = 8
}
