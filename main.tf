
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.cluster_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_associations" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policies" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(
      [for subnet in aws_subnet.public_subnets : subnet.id],   # Access public subnet IDs
      [for subnet in aws_subnet.private_subnets : subnet.id]  # Access private subnet IDs
    )
  }
    endpoint_public_access = true
    endpoint_private_access = false
    
  version = "1.26"

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                 = toset(var.availability_zones)
  vpc_id                   = aws_vpc.eks_vpc.id
  cidr_block               = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, index(var.availability_zones, each.key))
  availability_zone        = each.key
  map_public_ip_on_launch  = true
  tags                     = { Name = "${var.cluster_name}-public-${each.key}" }
}

resource "aws_subnet" "private_subnets" {
  for_each          = toset(var.availability_zones)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, length(var.availability_zones) + index(var.availability_zones, each.key))
  availability_zone = each.key
  tags              = { Name = "${var.cluster_name}-private-${each.key}" }
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_policies" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonEKS_CNI_Policy"
  ])

  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_security_group" "worker_group_sg" {
  name_prefix = "eks-worker-sg"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = values(aws_subnet.private_subnets)[*].id

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  instance_types = [var.instance_type]

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}



