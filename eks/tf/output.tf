output "eks_nodes_ip_addresses" {
  value = data.aws_instances.eks_nodes.public_ips
}
