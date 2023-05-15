resource "google_eventarc_trigger" "run-initial-cloud-build-trigger" {
    name = "run-initial-cloud-build-trigger"
    project = var.gcp_deployment_project_id
    location = "us-central1"
    matching_criteria {
        attribute = "methodName"
        value = "google.devtools.cloudbuild.v1.CloudBuild.CreateBuildTrigger"
    }
    timeouts {
    create = "30m"
    update = "40m"
    }
     matching_criteria {   
        attribute = "type"
        value = "google.cloud.audit.log.v1.written"
     }
    matching_criteria {
        attribute = "serviceName"
        value = "cloudbuild.googleapis.com"
    }
    destination {
        workflow = "projects/${var.gcp_deployment_project_id}/locations/us-central1/workflows/run-cloudbuild-trigger"
    }
    service_account = google_service_account.eventarc-service-account.name
    
    labels = {
        tag = "derf"
    }

    depends_on = [ 
        google_project_iam_member.project_iam_assignment1_eventarc_cmsa,
        google_project_iam_member.project_iam_assignment2_eventarc_cmsa,
        google_project_iam_member.project_iam_assignment_eventarc_agent
        ]
}

