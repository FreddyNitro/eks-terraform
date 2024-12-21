variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "my-eks-cluster"
}

variable "node_group_size" {
  description = "Number of worker nodes"
  default     = 2
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}