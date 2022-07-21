output "eks_node_ip_address" {
  value = data.aws_instance.eks_node.public_ip
}
