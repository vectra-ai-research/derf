##########################################################################################
# Complete the example-backend.conf for profile and region
# Once completed Run `tereraform init -backend-config=example-backend.conf
##########################################################################################

terraform {
  backend "s3" {
    encrypt        = true
    key            = "terraform.tfstate"
  }
}
