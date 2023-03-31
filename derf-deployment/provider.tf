provider "aws" {
  alias = "primary"
  region = var.region
  shared_credentials_files    = [var.pathToAWSConfig]
  profile                     = "${var.aws_primary_profile}"
  allowed_account_ids         = [local.aws_accounts["primary"]]
}

provider "aws" {
  alias  = "secondary"
  region = var.region
  shared_credentials_files  = [var.pathToAWSConfig]
  profile                   = "${var.aws_secondary_profile}"
  allowed_account_ids       = [local.aws_accounts["secondary"]]
}