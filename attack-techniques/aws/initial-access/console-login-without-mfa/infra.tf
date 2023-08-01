data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length    = 10
  min_lower = 10
  special   = false
}

locals {
  resource_prefix = "derf-login-user" 
}

resource "aws_iam_user" "console-user" {
  name          = "${local.resource_prefix}-${random_string.suffix.result}"
  force_destroy = true
}

// Allows the IAM user to authenticate through the AWS Console
resource "aws_iam_user_login_profile" "login-profile" {
  user                    = aws_iam_user.console-user.name
  password_length         = 16
  password_reset_required = false
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "username" {
  value = aws_iam_user.console-user.name
}

output "password" {
  value = aws_iam_user_login_profile.login-profile.password
}