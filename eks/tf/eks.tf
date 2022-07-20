resource "aws_eks_cluster" "training_eks_cluster" {
  name     = "training_eks_cluster"
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
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.training_eks_cluster.name
  addon_name    = "coredns"
  addon_version = "v1.8.7-eksbuild.1"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.training_eks_cluster.name
  addon_name    = "kube-proxy"
  addon_version = "v1.22.6-eksbuild.1"
}
