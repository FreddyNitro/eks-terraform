
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "eks.amazonaws.com" },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0" # Adjust based on compatibility
  cluster_name    = var.eks_cluster_name
  cluster_version = "1.27"

  vpc_id  = aws_vpc.main.id
  subnets = aws_subnet.private[*].id

  node_group_defaults = {
    instance_type = var.instance_type
  }

  managed_node_groups = {
    eks_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      key_name     = var.key_name
    }
  }
}


