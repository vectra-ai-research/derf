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
# CLoud Run Service-Level IAM Role Binding
# ---------------------------------------------------------------------------------------------------------------------


resource "google_cloud_run_v2_service_iam_member" "workflow_service_account" {
  location = local.location
  name = google_cloud_run_v2_service.aws-proxy-app.name
  project = local.gcp_deployment_project_id
  role = "roles/run.developer"
  member = google_service_account.workflows-to-cloudrun-service-account.member
}


# ---------------------------------------------------------------------------------------------------------------------
# Secret-Level Roles: Secret Accessor Role to the Service Accounts used by the Cloud Run App 
# and Cloud Build SA during Deployment Phase
# ---------------------------------------------------------------------------------------------------------------------

#Secrets Stored for DeRF User 1
resource "google_secret_manager_secret_iam_member" "binding_id_01_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user01_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}


resource "google_secret_manager_secret_iam_member" "binding_secret_01_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user01_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}



#Secrets Stored for DeRF User 2

resource "google_secret_manager_secret_iam_member" "binding_id_02_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}


resource "google_secret_manager_secret_iam_member" "binding_secret_02_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}



## Secrets Stored for the Default User

resource "google_secret_manager_secret_iam_member" "binding_id_default_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_default_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}


resource "google_secret_manager_secret_iam_member" "binding_secret_default_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_default_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
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


