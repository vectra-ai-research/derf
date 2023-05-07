# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CONTAINER REGIGISTY WHERE CLOUD BUILD WILL STORE ARITFACTS AND CLOUD BUILD WILL PULL FROM
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_registry" "derf-aws-app-proxy" {
  project  = var.gcp_deployment_project_id
  location = "US"
}


# ---------------------------------------------------------------------------------------------------------------------
# CONNECT TO PUBLIC DERF REPO VIA CLOUDBUILD GITHUB APP
# ---------------------------------------------------------------------------------------------------------------------

# resource "google_cloudbuildv2_connection" "github-cloudbuild-app-connection" {
#   provider = google-beta
#   location = "us-central1"
#   name = "github-cloudbuild-app"

#   github_config {
#     app_installation_id = 123123
#     authorizer_credential {
#       oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
#     }
#   }
# }

# resource "google_cloudbuildv2_repository" "derf-public" {
#   provider = google-beta
#   location = "us-central1"
#   name = "derf-public"
#   parent_connection = google_cloudbuildv2_connection.github-cloudbuild-app-connection.name
#   remote_uri = "https://github.com/vectra-ai-research/derf.git"
# }

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLOUD BUILD TRIGGER
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "aws_proxy_app_cloudbuild_trigger" {
  location    = "global"
  project     = local.gcp_deployment_project_id
  description = "Github Trigger ${local.repository_name} (${local.branch_name})"
  
  github {
    owner = "vectra-ai-research"
    name  = "derf"
    push {
      branch = "^main$"
    }

  }

  git_file_source {
    path      = "aws-proxy-app/cloudbuild.yaml"
    uri       = "https://github.com/vectra-ai-research/derf.git"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }
    approval_config {
     approval_required = true 
  }



  ignored_files = ["README.md", "derf-deployment/**", "docs/**",  "attack-techniques/**", "mkdocs.yaml", "/images/**"]

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
  project  = var.gcp_deployment_project_id

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

