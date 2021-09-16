data "aws_caller_identity" "current" {}

data "local_file" "pgp_public_key" {
  filename = "../../gpg/terraform.pub"
}
