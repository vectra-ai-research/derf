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


#########################################################################################
# GCP PROVIDERS
##########################################################################################

# To load credentials for this provider to your local system perform the following:
# `gcloud auth login --update-adc --project GCP_DEPLOYMENT_PROJECT_ID`
#########################################################################################
# More information on authenticating to GCP on your workstation for working with 
# The Google Terraform provider: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference

provider "google" {
  region  = "us-central1"
}

provider "google" {
  alias   = "derf"
  region  = "us-central1"
  project = "${var.gcp_deployment_project_id}"
  request_reason  = "derf-deployment"
}

provider "google-beta" {
  region  = "us-central1"
  project = "${var.gcp_deployment_project_id}"
  request_reason  = "derf-deployment"
}

