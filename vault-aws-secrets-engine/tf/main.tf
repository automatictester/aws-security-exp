// globals

terraform {
  backend "s3" {
    bucket = "automatictester-co-uk-aws-security-exp"
    key = "vault-aws-auth.tfstate"
    region = "eu-central-1"
  }
  required_providers {
    aws = {
      version = "3.57.0"
    }
  }
}

provider "aws" {
  region = var.region
}

// vault iam user

resource "aws_iam_user" "vault" {
  name = "vault"
}

resource "aws_iam_policy" "vault_core_user_policy" {
  name = "VaultCoreUserPolicy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "vault_core_user_policy_attachment" {
  user = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.vault_core_user_policy.arn
}

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
  pgp_key = data.local_file.pgp_public_key.content
}

output "aws_access_key_id" {
  value = aws_iam_access_key.vault.id
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.vault.encrypted_secret
}

// permissions assigned to vault-managed principals

resource "aws_iam_policy" "vault_assigned_policy" {
  name = "VaultAssignedPolicy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:DescribeRegions",
            "Resource": "*"
        }
    ]
}
EOF
}

// vault-assumed role

resource "aws_iam_role" "vault_assumed_role" {
  name = "VaultAssumedRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.vault.name}"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vault_role_policy_attachment" {
  role = aws_iam_role.vault_assumed_role.name
  policy_arn = aws_iam_policy.vault_assigned_policy.arn
}

resource "aws_iam_policy" "vault_assume_role_policy" {
  name = "VaultAssumeRolePolicy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement":
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.vault_assumed_role.name}"
    }
}
EOF
}

resource "aws_iam_user_policy_attachment" "vault_assume_role_policy_attachment" {
  user = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.vault_assume_role_policy.arn
}
