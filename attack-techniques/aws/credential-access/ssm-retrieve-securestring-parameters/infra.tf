locals {
  num_parameters = 42
  prefix         = "/credentials/derf/"
}

resource "random_password" "secret" {
  count     = local.num_parameters
  length    = 16
  min_lower = 16
}

resource "aws_ssm_parameter" "parameters" {
  count = local.num_parameters
  name  = "${local.prefix}credentials-${count.index}"
  type  = "SecureString"
  value = random_password.secret[count.index].result
}