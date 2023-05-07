# ---------------------------------------------------------------------------------------------------------------------
# New Customer Managed Service Account
# ---------------------------------------------------------------------------------------------------------------------
## Proxy App will run as this SA
resource "google_service_account" "aws-proxy-app-service-account" {
  account_id   = "aws-proxy-app-service-account"
  display_name = "Service Account for AWS Proxy App"
  project = local.gcp_deployment_project_id

}

## Cloud Build will deploy to app to Cloud Run with this SA
resource "google_service_account" "cloudbuild-to-cloudrun-deployment-service-account" {
  account_id   = "cloudbuild-deploy-cloudrun-sa"
  display_name = "Service Account Cloud Build used to deploy to the proxy app to Cloud Run"
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


resource "google_cloud_run_service_iam_member" "workflow_service_account" {
  location = local.location
  project = local.gcp_deployment_project_id
  service = google_cloud_run_service.aws-proxy-app.name
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

resource "google_secret_manager_secret_iam_member" "binding_id_01_cloudbuild" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user01_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.cloudbuild-to-cloudrun-deployment-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_01_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user01_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_01_cloudbuild" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user01_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.cloudbuild-to-cloudrun-deployment-service-account.member
}


#Secrets Stored for DeRF User 2

resource "google_secret_manager_secret_iam_member" "binding_id_02_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_id_02_cloudbuild" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member = google_service_account.cloudbuild-to-cloudrun-deployment-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_02_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_02_cloudbuild" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_user02_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.cloudbuild-to-cloudrun-deployment-service-account.member
}


## Secrets Stored for the Default User

resource "google_secret_manager_secret_iam_member" "binding_id_default_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_default_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_id_default_cloudbuild" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_default_accessKeyId_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member = google_service_account.cloudbuild-to-cloudrun-deployment-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_default_app" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_default_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.aws-proxy-app-service-account.member
}

resource "google_secret_manager_secret_iam_member" "binding_secret_default_cloudbuild" {
  project = var.gcp_deployment_project_id
  secret_id = var.derf_default_accessKeySecret_AWS_SMID
  role = "roles/secretmanager.secretAccessor"
  member =  google_service_account.cloudbuild-to-cloudrun-deployment-service-account.member
}
# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_iam_member" "project_iam_assignment_01" {
  project = var.gcp_deployment_project_id
  role    = "roles/run.admin"
  member  = google_service_account.cloudbuild-to-cloudrun-deployment-service-account.member
}

resource "google_project_iam_member" "project_iam_assignment_02" {
  project = var.gcp_deployment_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}


resource "google_project_iam_member" "project_iam_assignment_03" {
  project = var.gcp_deployment_project_id
  role = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "project_iam_assignment_04" {
  project = var.gcp_deployment_project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}



# ---------------------------------------------------------------------------------------------------------------------
# Assign Service Account User Role to the Default Cloud Build SA so it can impersonate the  Customer-Managed SA
# ---------------------------------------------------------------------------------------------------------------------

data "google_project" "project" {
  project_id = local.gcp_deployment_project_id
}

output "project_number" {
  value = data.google_project.project.number
}

resource "google_service_account_iam_member" "cloudbuild_serviceAccount_binding" {
  service_account_id = google_service_account.cloudbuild-to-cloudrun-deployment-service-account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [
    google_cloudbuild_trigger.aws_proxy_app_cloudbuild_trigger
  ]
}

