# ---------------------------------------------------------------------------------------------------------------------
# New Customer Managed Service Account
# ---------------------------------------------------------------------------------------------------------------------
## Proxy App will run as this SA
resource "google_service_account" "aws-proxy-app-service-account" {
  account_id   = "aws-proxy-app-service-account"
  display_name = "Service Account for AWS Proxy App"
  project = local.gcp_deployment_project_id

}


## Cloud Workflows will run as this SA to invoke Cloud Run
resource "google_service_account" "workflows-to-cloudrun-service-account" {
  account_id   = "workflows-to-cloudrun-sa"
  display_name = "Service Account Cloud Workflows will used to inbvoke the AWS proxy app in Cloud Run"
  project = local.gcp_deployment_project_id

}

# ---------------------------------------------------------------------------------------------------------------------
# Service-Account Level IAM
# ---------------------------------------------------------------------------------------------------------------------

## Allow the workflows SA to ActAs the default Compute SA
## Required for the custom user provisioning workflow and updating the CloudRun App ENVs

data "google_compute_default_service_account" "default" {
  project = local.gcp_deployment_project_id
}

resource "google_service_account_iam_member" "actas-gce-default-account-by-workflow-sa" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.workflows-to-cloudrun-service-account.member
}


## Allow the workflows P4SA to ActAs the default Compute SA
## Required for the custom user provisioning workflow and updating the CloudRun App ENVs

data "google_project" "current" {
  project_id = local.gcp_deployment_project_id
}

resource "google_service_account_iam_member" "act-as-gce-default-account-by-workflow-p4sa" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-workflows.iam.gserviceaccount.com"
}

# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM
# ---------------------------------------------------------------------------------------------------------------------

## Allow the Workflows SA to call other Workflows
resource "google_project_iam_member" "project_iam_assignment_05" {
  project = var.gcp_deployment_project_id
  role = "roles/workflows.invoker"
  member = google_service_account.workflows-to-cloudrun-service-account.member
}

## Allow the Cloud Run App to access all secrets in the Project
resource "google_project_iam_member" "project_iam_assignment_06" {
  project = var.gcp_deployment_project_id
  role = "roles/secretmanager.secretAccessor"
  member = google_service_account.aws-proxy-app-service-account.member
}


## Allow the Workflows the ability to manage secrets (create, update, destroy, access) in the project
resource "google_project_iam_member" "project_iam_assignment_07" {
  project = var.gcp_deployment_project_id
  role = "roles/secretmanager.admin"
  member = google_service_account.workflows-to-cloudrun-service-account.member
}

# Allow the Workflows SA to managed (create, update) all Cloud Run Resources.  
resource "google_project_iam_member" "project_iam_assignment_08" {
  project = var.gcp_deployment_project_id
  role = "roles/run.developer"
  member = google_service_account.workflows-to-cloudrun-service-account.member
}

# # Allow the Workflows SA to actAs from the project-level  
# resource "google_project_iam_member" "project_iam_assignment_09" {
#   project = var.gcp_deployment_project_id
#   role = "roles/iam.serviceAccountUser"
#   member = google_service_account.workflows-to-cloudrun-service-account.member
# }

# # Allow the Workflows P4SA to actAs from the project-level  
# resource "google_project_iam_member" "project_iam_assignment_10" {
#   project = var.gcp_deployment_project_id
#   role = "roles/iam.serviceAccountUser"
#   member = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-workflows.iam.gserviceaccount.com"
# }