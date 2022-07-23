resource "aws_eks_node_group" "eks_node_group" {
  node_group_name = "eks-node-group"
  cluster_name    = aws_eks_cluster.training_eks_cluster.name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [for k, v in var.subnets : aws_subnet.eks_vpc_subnet[k].id]

  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = "1"
  }

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

resource "aws_launch_template" "eks_node_launch_template" {
  name                   = "eks-node-launch-template"
  vpc_security_group_ids = [
    aws_security_group.eks_node_sg.id,
    aws_eks_cluster.training_eks_cluster.vpc_config[0].cluster_security_group_id
  ]
}
