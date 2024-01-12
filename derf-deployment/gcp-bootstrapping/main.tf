resource "google_project_service" "deployment_project_apis" {
  count   = length(local.enable_services)
  project = local.gcp_deployment_project_id
  service = local.enable_services[count.index]
  disable_on_destroy = false
  timeouts {
    create = "30m"
    update = "40m"
  }
}


resource "google_project_service" "derf_project_apis" {
  count   = length(local.enable_services)
  project = local.gcp_derf_project_id
  service = local.enable_services[count.index]
  disable_on_destroy = false
  timeouts {
    create = "30m"
    update = "40m"
  }
}

## Enable all Audit Logging for DeRF Target Project
resource "google_project_iam_audit_config" "target_all-services" {
  project = local.gcp_derf_project_id
  service = "allServices"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

## Enable all Audit Logging for DeRF Target Project
resource "google_project_iam_audit_config" "deploymentall-services" {
  project = local.gcp_deployment_project_id
  service = "allServices"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}


module "enable_cross_project_service_account_usage" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 5.1"

  project_id  = local.gcp_derf_project_id
  policy_for  = "project"
  policy_type = "boolean"
  enforce     = "false"
  constraint  = "constraints/iam.disableCrossProjectServiceAccountUsage"
}