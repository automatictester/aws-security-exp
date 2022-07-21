resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "eks_vpc_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route_table" "eks_vpc_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_igw.id
  }
}

resource "aws_subnet" "eks_vpc_subnet" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.eks_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${each.key}"
  cidr_block              = each.value

  tags = {
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table_association" "rt_association" {
  for_each = aws_subnet.eks_vpc_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.eks_vpc_rt.id
}

resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "eks-node-sg"
  vpc_id      = aws_vpc.eks_vpc.id
}

resource "aws_security_group_rule" "ingress_allow_all_from_my_public_ip" {
  security_group_id = aws_security_group.eks_node_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [
    "${data.external.my_public_ip.result.ip}/32"
  ]
}

resource "aws_security_group_rule" "egress_allow_all" {
  security_group_id = aws_security_group.eks_node_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [
    "0.0.0.0/0"
  ]
}
