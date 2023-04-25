locals {
  enable_services = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "run.googleapis.com",
    "storage-component.googleapis.com",
    "workflowexecutions.googleapis.com",
    "workflows.googleapis.com",
    "containerregistry.googleapis.com",
    "sourcerepo.googleapis.com",
  ]
  gcp_deployment_project_id = var.gcp_deployment_project_id
}