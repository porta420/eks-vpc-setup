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

variable "my_ip" {
  description = "Your public IP address to allow SSH access"
  type        = string
  default     = "64.246.65.126/32" # ⚠️ Replace with your actual IP, e.g. "203.0.113.25/32"
}

variable "key_name" {
  description = "SSH key pair name for accessing the bastion host"
  type        = string
  default     = "ansible" # ⚠️ Replace with your actual key name
  
}