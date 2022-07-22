data "external" "my_public_ip" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

data "aws_ami" "amazon_linux_2" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.22-v20220629"]
  }
}

data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = ["training-eks-cluster"]
  }
  depends_on = [aws_eks_node_group.eks_node_group]
}
