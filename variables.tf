# AWS Region
variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

# EKS Cluster Name
variable "cluster_name" {
  description = "Name of the EKS Cluster"
  default     = "my-eks-cluster"
}

# EKS Node Group Size
variable "node_group_size" {
  description = "Number of worker nodes in the EKS node group"
  default     = 3
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Subnets CIDR Blocks
variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
