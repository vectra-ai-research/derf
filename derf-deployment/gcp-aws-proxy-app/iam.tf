# ---------------------------------------------------------------------------------------------------------------------
# New Customer Managed Service Account
# ---------------------------------------------------------------------------------------------------------------------
## Proxy App will run as this SA
resource "google_service_account" "aws-proxy-app-service-account" {
  account_id   = "aws-proxy-app-service-account"
  display_name = "Service Account for AWS Proxy App"

}

## Cloud Build will deploy to app to Cloud Run with this SA
resource "google_service_account" "cloudbuild-to-cloudrun-deployment-service-account" {
  account_id   = "cloudbuild-deploy-cloudrun-sa"
  display_name = "Service Account Cloud Build used to deploy to the proxy app to Cloud Run"

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

# ---------------------------------------------------------------------------------------------------------------------
# Assign Cloud Run Developer Role to the Cloud Build Service Agent - (Cloud Build Role automatically assigned)
# ---------------------------------------------------------------------------------------------------------------------

data "google_project" "project" {
}

output "project_number" {
  value = data.google_project.project.number
}

resource "google_project_iam_member" "project_iam_assignment_01" {
  project = var.gcp_deployment_project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
  depends_on = [
    google_cloudbuild_trigger.aws_proxy_app_cloudbuild_trigger
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Assign Service Account User Role to the Default Cloud Build Service Account so it can impersonate the Service Agent
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account_iam_member" "cloudbuild_serviceAccount_binding" {
  service_account_id = google_service_account.cloudbuild-to-cloudrun-deployment-service-account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [
    google_cloudbuild_trigger.aws_proxy_app_cloudbuild_trigger
  ]
}