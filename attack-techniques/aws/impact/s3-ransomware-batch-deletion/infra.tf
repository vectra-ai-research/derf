locals {
  num_secrets     = 20
  resource_prefix = "derf-retrieve-secret"
}

resource "random_string" "secrets" {
  count     = local.num_secrets
  length    = 16
  min_lower = 16
}

resource "aws_secretsmanager_secret" "secrets" {
  count = local.num_secrets
  name  = "${local.resource_prefix}-${count.index}"

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret-values" {
  count         = local.num_secrets
  secret_id     = aws_secretsmanager_secret.secrets[count.index].id
  secret_string = random_string.secrets[count.index].result
}