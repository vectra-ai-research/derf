# ---------------------------------------------------------------------------------------------------------------------
# New Customer Managed Service Account
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account" "derf-attacker-SA-01" {
  account_id   = "derf-attacker-sa-01"
  display_name = "Service Account to execute attacks as"
  project = var.gcp_derf_project_id

}

resource "google_service_account" "derf-attacker-SA-02" {
  account_id   = "derf-attacker-sa-02"
  display_name = "Service Account to execute attacks as"
  project = var.gcp_derf_project_id

}

# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM - Assign the execution users baseline permissions in the attack execution project
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_iam_member" "project_iam_assignment_SA_01" {
  project = var.gcp_derf_project_id
  role    = "roles/viewer"
  member  = google_service_account.derf-attacker-SA-01.member
  depends_on = [ google_service_account.derf-attacker-SA-01 ]
}

resource "google_project_iam_member" "project_iam_assignment_SA_02" {
  project = var.gcp_derf_project_id
  role    = "roles/viewer"
  member  = google_service_account.derf-attacker-SA-02.member
  depends_on = [ google_service_account.derf-attacker-SA-02 ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Service-Account Level Permissions - Grants the Workflows SA the ability to impersonate the DeRF Attacker SA's
# ---------------------------------------------------------------------------------------------------------------------


resource "google_service_account_iam_member" "derf-attacker-SA-01_binding" {
  service_account_id = google_service_account.derf-attacker-SA-01.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.workflows-to-cloudrun-service-account_member
  depends_on = [
    google_service_account.derf-attacker-SA-01
  ]
}

resource "google_service_account_iam_member" "derf-attacker-SA-02_binding" {
  service_account_id = google_service_account.derf-attacker-SA-02.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.workflows-to-cloudrun-service-account_member
  depends_on = [
    google_service_account.derf-attacker-SA-02
  ]
}