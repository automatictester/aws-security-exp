variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  type = map(string)

  default = {
    "a" = "10.0.1.0/24",
    "b" = "10.0.2.0/24",
    "c" = "10.0.3.0/24",
  }
}

variable "k8s_version" {
  type = string
  default = "1.22"
}
