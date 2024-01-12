#####################################################################################
## Infrastructure
######################################################################################
# This workflow relies on a Biquery dataset and table pre-populated within
# the gcp perpetual range and deployed in the GCP Project defined in the 
# .tfvars file as the:'gcp_derf_project_id'

## Random data inserted
resource "random_string" "fullVisitorId" {
  length           = 16
}


resource "random_string" "longDigits" {
  length            = 16
  lower             = false
  upper             = false
  special           = false
}

resource "random_string" "digits" {
  length            = 2
  lower             = false
  upper             = false
  special           = false
}