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
# Project-Level IAM - Assign the execution users full owner permissions in the target project.
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_iam_member" "project_iam_assignment_SA_01" {
  project = var.gcp_derf_project_id
  role    = "roles/owner"
  member  = google_service_account.derf-attacker-SA-01.member
  depends_on = [ google_service_account.derf-attacker-SA-01 ]
}

resource "google_project_iam_member" "project_iam_assignment_SA_02" {
  project = var.gcp_derf_project_id
  role    = "roles/owner"
  member  = google_service_account.derf-attacker-SA-02.member
  depends_on = [ google_service_account.derf-attacker-SA-02 ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM - Assign the execution users the ability to write log entries in the DEPLOYMENT project
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_iam_member" "project_logging_assignment_SA_01" {
  project = var.gcp_deployment_project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.derf-attacker-SA-01.member
  depends_on = [ google_service_account.derf-attacker-SA-01 ]
}

resource "google_project_iam_member" "project_logging_assignment_SA_02" {
  project = var.gcp_deployment_project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.derf-attacker-SA-02.member
  depends_on = [ google_service_account.derf-attacker-SA-02 ]
}



# ---------------------------------------------------------------------------------------------------------------------
# Service-Account Level Permissions - Grants the Workflows CMSA the ability to impersonate the DeRF Attacker SA's
# This binding is used when attack techniques access Google APIs via their URL and not with the Workflows Connectors.
# ---------------------------------------------------------------------------------------------------------------------


resource "google_service_account_iam_member" "derf-attacker-SA-01_binding_1" {
  service_account_id = google_service_account.derf-attacker-SA-01.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.workflows-to-cloudrun-service-account_member
  depends_on = [
    google_service_account.derf-attacker-SA-01
  ]
}

resource "google_service_account_iam_member" "derf-attacker-SA-02_binding_1" {
  service_account_id = google_service_account.derf-attacker-SA-02.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.workflows-to-cloudrun-service-account_member
  depends_on = [
    google_service_account.derf-attacker-SA-02
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Project-Level Assignment - Grants the Workflows Service-Agent (GMSA) the ability to impersonate SA's
# This binding is used when Workflow Connectors are used in the attack techniques rather than accessing via http.post
# ---------------------------------------------------------------------------------------------------------------------

data "google_project" "deployment" {
  project_id = var.gcp_deployment_project_id
}

# Allow the Workflows P4SA to actAs from the project-level of the target project (in order to impersonate the attacker SA's 
resource "google_project_iam_member" "project_iam_assignment" {
  project = var.gcp_derf_project_id
  role = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:service-${data.google_project.deployment.number}@gcp-sa-workflows.iam.gserviceaccount.com"
}


