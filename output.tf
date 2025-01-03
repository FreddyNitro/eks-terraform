output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "node_role_arn" {
  value = aws_iam_role.eks_node_group.arn
}

