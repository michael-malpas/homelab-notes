variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cdir address"
  type        = string
}

variable "public_subnet_cidr" {
  description = "public ip subnet cidr"
  type        = string
}

variable "private_subnet_cidr" {
  description = "private ip subnet cidr"
  type        = string
}

variable "availability_zone" {
  description = "availability zone definition"
  type        = string
}
