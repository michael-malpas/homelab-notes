variable "instance_count" {
  type = number
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "user_data" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "server_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "subnet_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}
