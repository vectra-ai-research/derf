
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A GOOGLE CLOUD STORAGE BUCKET AND UPLOAD PROXY APP CODE
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLOUD BUILD TRIGGER
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "aws_proxy_app_cloudbuild_trigger" {
  location    = "global"
  project     = local.gcp_deployment_project_id
  description = "Github Trigger ${local.repository_name} (${local.branch_name})"
  
  github {
    owner = "Vectra AI Research"
    name  = "derf-vectra-private"
    push {
      branch = "^main$"
    }

  }

  git_file_source {
    path      = "cloudbuild.yaml"
    uri       = "https://github.com/vectra-ai-research/derf-vectra-private.git"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }
    approval_config {
     approval_required = true 
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  ignored_files = ["README.md"]

  # These substitutions have been defined in the sample app's cloudbuild.yaml file.
  # See: https://github.com/robmorgan/sample-docker-app/blob/master/cloudbuild.yaml#L43
  substitutions = {
    _LOCATION             = local.location
    _GCR_REGION           = local.gcr_region
    _SERVICE_NAME         = local.service_name
    _PLATFORM             = "managed"
    _SERVICE_NAME         = local.service_name
    _TARGET_PROJECT       = local.source_project_id
    _DEFAULT_COMPUTE_SA   =  local.default_compute_sa
    _DEPLOY_REGION        = local.deploy_region
    _SOURCE_PROJECT_ID    = local.source_project_id
    _GCR_HOSTNAME         = local.gcr_hostname 
  }

}