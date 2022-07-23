data "external" "my_public_ip" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = ["training-eks-cluster"]
  }
  depends_on = [aws_eks_node_group.eks_node_group]
}
