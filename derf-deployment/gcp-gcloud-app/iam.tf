# ---------------------------------------------------------------------------------------------------------------------
# New Customer Managed Service Account
# ---------------------------------------------------------------------------------------------------------------------
## GCloud App will run as this SA
resource "google_service_account" "gcloud-app-service-account" {
  account_id   = "gcloud-app-service-account"
  display_name = "Service Account for GCloud App"
  project = local.gcp_deployment_project_id

}



# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM
# ---------------------------------------------------------------------------------------------------------------------


# Allow the GCloud SA to managed (create, update) all Cloud Run Resources.  
resource "google_project_iam_member" "project_iam_assignment_10" {
  project = var.gcp_deployment_project_id
  role = "roles/run.developer"
  member = google_service_account.gcloud-app-service-account.member
}

