resource "aws_launch_template" "eks_node_group" {
  name          = "eks-launch-template"
  image_id      = data.aws_ami.eks.id
  instance_type = var.instance_type

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${var.eks_cluster_name}
  EOT
  )

  network_interfaces {
    security_groups = [aws_security_group.eks_node_group.id]
  }
}

data "aws_ami" "eks" {
  most_recent = true
  owners      = ["602401143452"] # EKS AMI Owner
  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }
}
