# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A CLOUD RUN SERVICE
# ------------------------------------------------------------------------------------------

resource "google_cloud_run_v2_service" "gcloud-app" {
  name     = "gcloud-app"
  location = local.location
  project  = var.gcp_deployment_project_id
  ingress = "INGRESS_TRAFFIC_ALL"

## Template Block
  template {

      service_account  = "${google_service_account.gcloud-app-service-account.email}"

    containers {
      image = "us-docker.pkg.dev/derf-artifact-registry-public/gcloud-app/gcloud-app:latest"
      
      env {
        name = "PROJECT_ID"
        value = var.gcp_deployment_project_id
      }


    }

    }
    depends_on = [ google_project_iam_member.project_iam_assignment_10]
    
    lifecycle {
    ignore_changes = all
      }

  }


