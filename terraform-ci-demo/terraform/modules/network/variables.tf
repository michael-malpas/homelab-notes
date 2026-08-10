variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cdir address"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "public ip subnet cidr"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "private ip subnet cidr"
  type        = list(string)
}

variable "availability_zones" {
  description = "availability zone definition"
  type        = list(string)
}
