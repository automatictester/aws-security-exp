resource "aws_launch_template" "eks_node_launch_template" {
  name = "eks_node_launch_template"

  block_device_mappings {
    ebs {
      volume_size = 20
    }
  }

  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.eks_node_sg.id]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.training_eks_cluster.name
  node_group_name = "eks_node_group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [for k, v in var.subnets : aws_subnet.eks_vpc_subnet[k].id]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_worker_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_ecr_policy_attachment
  ]
}
