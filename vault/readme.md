Export GPG public key to get `aws_secret_access_key` (this assumes GPG key named `terraform` already exists):

```shell
gpg --export -a "terraform" | sed "1,2d" | sed "$ d" | sed "$ d" > gpg/terraform.pub
```

Get `aws_secret_access_key` after running `terraform apply`:

```shell
terraform output aws_secret_access_key | sed -e 's/^"//' -e 's/"$//' | base64 --decode | gpg --decrypt
```
