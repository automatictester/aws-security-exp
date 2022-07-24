data "aws_caller_identity" "current" {}

data "external" "my_public_ip" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = [var.cluster_name]
  }
  depends_on = [aws_eks_node_group.eks_node_group]
}

data "tls_certificate" "oidc_provider_tls_certificate" {
  url = aws_eks_cluster.training_eks_cluster.identity[0].oidc[0].issuer
}
