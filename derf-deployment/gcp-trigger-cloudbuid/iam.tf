data "google_project" "project" {
  project_id = var.gcp_deployment_project_id
}

output "project_number" {
  value = data.google_project.project.number
}


# ---------------------------------------------------------------------------------------------------------------------
# New Customer Managed Service Account for Workflows to CloudBuild
# ---------------------------------------------------------------------------------------------------------------------

## Only the `run-cloudbuild-trigger` Workflow will run as this Service Account
resource "google_service_account" "workflows-to-cloudbuild-service-account" {
  account_id   = "workflows-to-cloudbuild-sa"
  display_name = "Service Account used by the run-cloudbuild-trigger only"
  project = var.gcp_deployment_project_id

}

# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM
# ---------------------------------------------------------------------------------------------------------------------



resource "google_project_iam_member" "project_iam_assignment1_workflow_cmsa" {
  project = var.gcp_deployment_project_id
  role    = "roles/cloudbuild.builds.approver"
  member  = google_service_account.workflows-to-cloudbuild-service-account.member
  depends_on = [ google_service_account.workflows-to-cloudbuild-service-account ]
}

resource "google_project_iam_member" "project_iam_assignment2_workflow_cmsa" {
  project = var.gcp_deployment_project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = google_service_account.workflows-to-cloudbuild-service-account.member
  depends_on = [ google_service_account.workflows-to-cloudbuild-service-account ]
}



