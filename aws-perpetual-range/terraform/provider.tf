provider "aws" {
  region = var.region
  shared_credentials_files    = [var.pathToAWSConfig]
  profile                     = "${var.awsProfile}"
  allowed_account_ids         = [var.awsAccountId]
}

provider "aws" {
  alias  = "external"
  region = var.region
  shared_credentials_files  = [var.pathToAWSConfig]
  profile                   = "${var.awsExternalProfile}"
  allowed_account_ids       = [var.awsExternalAccountId]
}