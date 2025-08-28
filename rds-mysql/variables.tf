variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

# Remote state (VPC)
variable "vpc_remote_state_bucket" {
  description = "S3 bucket where VPC state is stored"
  type        = string
  default     = "noel-s3-tf-state-bucket"
}

variable "vpc_remote_state_key" {
  description = "S3 key for VPC state file"
  type        = string
  # For your public setup example:
  default     = "vpc/terraform.tfstate"
}

# Remote state (EKS)
variable "eks_remote_state_bucket" {
  description = "S3 bucket where EKS state is stored"
  type        = string
  default     = "noel-s3-tf-state-bucket"
}

variable "eks_remote_state_key" {
  description = "S3 key for EKS state file"
  type        = string
  default     = "eks-public/terraform.tfstate"
}

variable "project_name" {
  description = "Project name prefix for tagging/naming"
  type        = string
  default     = "project022d"
}

# DB configuration
variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "mydbuser"
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ (recommended for prod)"
  type        = bool
  default     = false
}

# Networking placement
variable "use_private_subnets" {
  description = "Place RDS in private subnets (prod) instead of public (test)"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the DB has a public endpoint (test only)"
  type        = bool
  default     = true
}

# Optional: allow temporary access from your IP(s) for testing
variable "extra_db_ingress_cidrs" {
  description = "List of CIDR blocks allowed to access DB (e.g., your workstation IP /32)"
  type        = list(string)
  default     = []
}
