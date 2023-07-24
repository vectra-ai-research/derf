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
resource "google_project_iam_audit_config" "all-services" {
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