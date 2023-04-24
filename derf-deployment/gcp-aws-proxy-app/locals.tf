locals {
  gcp_deployment_project_id       = var.gcp_deployment_project_id
  source_project_id               = var.gcp_deployment_project_id
  location                        = "us-central1"
  deploy_region                   = "us-central1"
  gcr_region                      = "us-central1"
  image_name                      = "derf-aws-proxy-app-image"
  repository_name                 = "derf-aws-proxy-app-repo"
  branch_name                     = "main"
  service_name                    = "aws-proxy-app"
  gcr_hostname                    = "us.gcr.io"
  default_compute_sa              = "${var.gcp_deployment_project_id}@developer.gserviceaccount.com"
}