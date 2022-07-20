data "external" "my_public_ip" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

data "aws_ami" "amazon_linux_2" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-gp2"]
  }
}
