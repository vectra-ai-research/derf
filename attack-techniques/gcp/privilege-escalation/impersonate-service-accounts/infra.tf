#####################################################################################
## Create 10 Service Accounts in the Target Attacker Project
######################################################################################
locals {
  num-service-accounts = 10
  resource_prefix      = "derf-target-sa"
}

resource "random_string" "suffix" {
  count     = local.num-service-accounts
  length    = 4
  special   = false
  min_lower = 4
}

// Create N service accounts
resource "google_service_account" "service_account" {
  count           = local.num-service-accounts
  project         = var.gcp_derf_project_id
  account_id  = format("%s-sa-%s", local.resource_prefix, random_string.suffix[count.index].result)
  description = "Service account used by The DeRF during the Impersonate Service Account Attack Technique"
}


// Allow both of the DeRF Execution Users to impersonate a single of the created service accounts
resource "google_service_account_iam_policy" "iam_policy" {
  service_account_id = google_service_account.service_account[local.num-service-accounts - 1].name
  policy_data        = data.google_iam_policy.allow-impersonation.policy_data
}

data "google_iam_policy" "allow-impersonation" {
  binding {
    role = "roles/iam.serviceAccountTokenCreator"
    members = [
      var.derf-attacker-SA-01_member, var.derf-attacker-SA-02_member
    ]
  }
}

