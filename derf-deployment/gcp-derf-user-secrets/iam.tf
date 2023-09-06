# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM
# ---------------------------------------------------------------------------------------------------------------------

data "google_compute_default_service_account" "default" {
  project = local.gcp_deployment_project_id
}

## Allow the default computer service account the ability to access all secrets. 
### This is the SA the Cloud Run App runs as when accessing secrets.
## Required for the custom user provisioning workflow.
resource "google_project_iam_member" "project_iam_assignment_compute_to_secrets" {
  project = var.gcp_deployment_project_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}