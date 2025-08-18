variable "region" {
  default = "eu-north-1"
}

variable "project_name" {
  default = "project022d"
}

variable "vpc_cidr" {
  default = "10.50.0.0/16"
}

variable "public_subnets" {
  default = ["10.50.0.0/18", "10.50.64.0/18"]
}

variable "private_subnets" {
  default = ["10.50.128.0/18", "10.50.192.0/18"]
}

