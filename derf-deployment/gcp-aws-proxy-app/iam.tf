resource "google_service_account" "aws-proxy-app-service-account" {
  account_id   = "aws-proxy-app-service-account"
  display_name = "Service Account for AWS Proxy App"

}


# ---------------------------------------------------------------------------------------------------------------------
# Assign Secret Accessor Role to the Service Account used by the Cloud Run App
# ---------------------------------------------------------------------------------------------------------------------

resource "google_secret_manager_secret_iam_member" "binding_id_01" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user01_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_01" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user01_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_id_02" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_02" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}