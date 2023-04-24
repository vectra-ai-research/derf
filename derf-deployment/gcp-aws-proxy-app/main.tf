
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A GOOGLE CLOUD STORAGE BUCKET AND UPLOAD PROXY APP CODE
# ---------------------------------------------------------------------------------------------------------------------

resource "random_uuid" "random" {
}


resource "google_storage_bucket" "derf-aws-proxy-app-bucket" {
 name          = "derf-aws-proxy-app-${random_uuid.random.result}"
 location      = "US"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}


resource "google_storage_bucket_object" "derf-aws-proxy-app-folder" {
 name         = "derf-aws-proxy-app"
 source       = "OBJECT_PATH"
 bucket       = google_storage_bucket.derf-aws-proxy-app-bucket.id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLOUD BUILD TRIGGER
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "aws_proxy_app_cloudbuild_trigger" {
  location = "global"
  description = "Cloud Source Repository Trigger ${local.repository_name} (${local.branch_name})"

  trigger_template {
    branch_name = local.branch_name
    repo_name   = local.repository_name
  }
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

  # The filename argument instructs Cloud Build to look for a file in the root of the repository.
  filename = "cloudbuild.yaml"

  depends_on = [google_sourcerepo_repository.aws-proxy-app-repo]
}