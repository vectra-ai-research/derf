data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id      = "workflows-to-cloudrun-sa"
  project         = var.projectId

}

resource "google_eventarc_trigger" "run-initial-cloud-build-trigger" {
    name = "run-initial-cloud-build-trigger"
    location = "us-central1"
    matching_criteria {
        attribute = "methodName"
        value = "google.devtools.cloudbuild.v1.CloudBuild.CreateBuildTrigger"
    }
     matching_criteria {   
        attribute = "type"
        value = "google.cloud.audit.log.v1.written"
     }
    matching_criteria {
        attribute = "serviceName"
        value = "cloudbuild.googleapis.com"
    }
    }
    destination {
        workflow {
            service = "projects/${var.projectId}/locations/us-central1/workflows/aws-attack-tools"
            region = "us-central1"
        }
    }
    service_account = google_service_account.eventarc-service-account.name
    labels = {
        tag = "derf"
    }
}