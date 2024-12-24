output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}

output "node_group_arn" {
  value = aws_eks_node_group.node_group.node_group_arn
}
