resource "aws_eks_cluster" "training_eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids              = [for s in aws_subnet.eks_vpc_subnet : s.id]
    public_access_cidrs     = ["${data.external.my_public_ip.result.ip}/32"]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.training_eks_cluster.name
  addon_name    = "vpc-cni"
  addon_version = "v1.10.1-eksbuild.1"
  depends_on    = [aws_eks_node_group.eks_node_group]
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.training_eks_cluster.name
  addon_name    = "coredns"
  addon_version = "v1.8.7-eksbuild.1"
  depends_on    = [aws_eks_node_group.eks_node_group]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.training_eks_cluster.name
  addon_name    = "kube-proxy"
  addon_version = "v1.22.6-eksbuild.1"
  depends_on    = [aws_eks_node_group.eks_node_group]
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.training_eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.8.0-eksbuild.0"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_service_account_role.arn
  depends_on               = [aws_eks_node_group.eks_node_group]
}
