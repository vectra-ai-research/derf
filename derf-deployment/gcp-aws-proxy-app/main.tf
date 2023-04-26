

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLOUD BUILD TRIGGER
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "aws_proxy_app_cloudbuild_trigger" {
  location    = "global"
  project     = local.gcp_deployment_project_id
  description = "Github Trigger ${local.repository_name} (${local.branch_name})"
  
  github {
    owner = "vectra-ai-research"
    name  = "derf-vectra-private"
    push {
      branch = "^main$"
    }

  }

  git_file_source {
    path      = "aws-proxy-app/cloudbuild.yaml"
    uri       = "https://github.com/vectra-ai-research/derf-vectra-private.git"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }
    approval_config {
     approval_required = true 
  }


  ignored_files = ["README.md", "./derf-deployment", "./docs", "./aws-perpetual-range", "mkdocs.yaml"]

# Substitutions key names must begin with underscore and will swap out values in the cloudbuild yaml file.
  substitutions = {
      # Defined in cloudbuild.yaml
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLOUD RUN SERVICE
# ---------------------------------------------------------------------------------------------------------------------

data "google_container_registry_image" "aws-proxy-app" {
  name      = "derf-vectra-private/aws-proxy-app"
  project   = local.gcp_deployment_project_id
  region    = "us"
  tag       = "" 
}

resource "google_cloud_run_service" "aws-proxy-app" {
  name     = "aws-proxy-app"
  location = "us-central1"  

  template {
    spec {
      containers {
        image = "us.gcr.io/vectra-sr-derf-deployment/derf-vectra-private/aws-proxy-app:61b5a6900b93724dff4f3a4520c79f6ce9bdb1b1"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [
    google_cloudbuild_trigger.aws_proxy_app_cloudbuild_trigger,
    google_project_iam_member.project_iam_assignment_01
  ]
}