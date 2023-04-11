resource "google_project_service" "project_apis" {
  count   = length(local.enable_services)
  project = local.gcp_deployment_project_id
  service = local.enable_services[count.index]
  disable_on_destroy = false
  timeouts {
    create = "30m"
    update = "40m"
  }
}