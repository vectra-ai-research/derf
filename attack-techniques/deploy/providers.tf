#########################################################################################
# AWS PROVIDERS
##########################################################################################

# Ensure credentials are loaded in your local system by performing:
# `aws sso login --profile aws_primary_profile`
# `aws sso login --profile aws_secondary_profile`

provider "aws" {
  region = "us-east-1"
  profile                     = "${var.aws_primary_profile}"
  allowed_account_ids         = [var.aws_primary_id]
}

provider "aws" {
  alias                       = "primary"
  region                      = "${var.region}"
  profile                     = "${var.aws_primary_profile}"
  allowed_account_ids         = [var.aws_primary_id]

}

provider "aws" {
  alias                     = "secondary"
  region                    = "${var.region}"
  profile                   = "${var.aws_secondary_profile}"
  allowed_account_ids       = [var.secondary_id]
}