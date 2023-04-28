# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CONTAINER REGIGISTY WHERE CLOUD BUILD WILL STORE ARITFACTS AND CLOUD BUILD WILL PULL FROM
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_registry" "derf-vectra-private" {
  project  = var.gcp_deployment_project_id
  location = "US"
}


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



  ignored_files = ["README.md", "/derf-deployment/*/*", "./docs/*/*", "./aws-perpetual-range/*/*", "./attack-techniques/*/*/*","mkdocs.yaml"]

# Substitutions key names must begin with underscore and will swap out values in the cloudbuild yaml file.
  substitutions = {
      # Defined in cloudbuild.yaml
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A CLOUD RUN SERVICE
# ------------------------------------------------------------------------------------------


resource "google_cloud_run_service" "aws-proxy-app" {
  name     = "aws-proxy-app"
  location = local.location

  template {
    metadata {
      annotations = {
        "client.knative.dev/user-image"         =   local.image_name
        "run.googleapis.com/client-name"        =    "terraform"

      }
    }

    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
      service_account_name  = "${google_service_account.aws-proxy-app-service-account.email}"
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }  
  depends_on = [ google_cloudbuild_trigger.aws_proxy_app_cloudbuild_trigger ]
  
  lifecycle {
    ignore_changes = all
  }


}

