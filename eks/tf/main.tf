terraform {
  backend "s3" {
    bucket = "automatictester-co-uk-aws-exp"
    key    = "eks.tfstate"
    region = "eu-west-1"
  }
  required_providers {
    aws = {
      version = "4.22.0"
    }
    external = {
      version = "2.2.2"
    }
    tls = {
      version = "3.4.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name = "training-eks-cluster"
    }
  }
}
