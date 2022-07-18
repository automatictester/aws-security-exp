// globals

terraform {
  backend "s3" {
    bucket = "automatictester-co-uk-aws-exp"
    key = "vault-aws-seal.tfstate"
    region = "eu-west-1"
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

// kms key

resource "aws_kms_key" "vault_seal_key" {
  description = "Vault seal key"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled = true
  enable_key_rotation = false
  deletion_window_in_days = 7
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${data.aws_caller_identity.current.arn}"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.vault_seal_key_user.arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_kms_alias" "vault_seal_key_alias" {
  name = "alias/VaultSealKey"
  target_key_id = aws_kms_key.vault_seal_key.key_id
}

// vault iam user

resource "aws_iam_user" "vault_seal_key_user" {
  name = "vault-seal-key-user"
}

resource "aws_iam_policy" "vault_seal_key_user_policy" {
  name = "VaultSealKeyUserPolicy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey"
      ],
      "Resource": [
        "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.vault_seal_key.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "vault_seal_key_user_policy_attachment" {
  user = aws_iam_user.vault_seal_key_user.name
  policy_arn = aws_iam_policy.vault_seal_key_user_policy.arn
}

resource "aws_iam_access_key" "vault_seal_key_user_access_key" {
  user = aws_iam_user.vault_seal_key_user.name
  pgp_key = data.local_file.pgp_public_key.content
}

// outputs

output "aws_access_key_id" {
  value = aws_iam_access_key.vault_seal_key_user_access_key.id
}

output "aws_kms_key_id" {
  value = aws_kms_key.vault_seal_key.id
}

output "aws_kms_key_region" {
  value = var.region
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.vault_seal_key_user_access_key.encrypted_secret
}
