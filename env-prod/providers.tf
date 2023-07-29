#########################################################################################
# AWS PROVIDERS
##########################################################################################

## Execute terraform with AWS SSO:
### export AWS_PROFILE=PROFILE \
### aws sso login --profile PROFILE \
### terraform plan -var-file=derf.tfvars

## Utilize AWS Vault:
### aws-vault exec PROFILE -- terraform plan -var-file=derf.tfvars


provider "aws" {
  alias                       = "target"
  skip_region_validation      = true
  skip_credentials_validation = true
  allowed_account_ids         = [local.aws_account_id]

}



#########################################################################################
# GCP PROVIDERS
##########################################################################################

# To load credentials for this provider to your local system perform the following:
# `gcloud auth login --update-adc --project GCP_DEPLOYMENT_PROJECT_ID`

# To load credentials for this provider to your local system perform the following:
# `gcloud auth login --update-adc --project GCP_DERF_PROJECT_ID`
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

