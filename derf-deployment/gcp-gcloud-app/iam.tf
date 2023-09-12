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
# Service-Account Level IAM
# ---------------------------------------------------------------------------------------------------------------------

## Allow the GCloud App SA to ActAs the default Compute SA

data "google_compute_default_service_account" "default" {
  project = local.gcp_deployment_project_id
}

resource "google_service_account_iam_member" "actas-gce-default-account-by-workflow-sa" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.gcloud-app-service-account.member
}

## Allow the GCloud App SA to ActAs the Proxy App Service Account so it can relaunch a new version when updating users.

data "google_project" "current" {
  project_id = local.gcp_deployment_project_id
}

resource "google_service_account_iam_member" "actas-proxy-app-sa" {
  service_account_id = var.aws-proxy-app-service-account_id
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.gcloud-app-service-account.member
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

