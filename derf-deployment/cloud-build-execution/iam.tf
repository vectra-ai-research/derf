# ---------------------------------------------------------------------------------------------------------------------
# New Customer Managed Service Account for EventArc
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account" "eventarc-service-account" {
  account_id   = "eventarc-service-account"
  display_name = "EventArc Trigger will run as this Service Account"
  project = local.gcp_deployment_project_id

}


# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_iam_member" "project_iam_assignment_eventarc" {
  project = var.gcp_deployment_project_id
  role    = "roles/eventarc.eventReceiver"
  member  = google_service_account.eventarc-service-account.member
}