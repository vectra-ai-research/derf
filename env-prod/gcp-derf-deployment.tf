#########################################################################################
# Ensure APIs are configured for the GCP Project
##########################################################################################
module "gcp_bootstrapping" {
  source = "../derf-deployment/gcp-bootstrapping"

  gcp_deployment_project_id  = local.gcp_deployment_project_id


}
#########################################################################################
# Store AWS Access Keys and Secrets as GCP Secrets
##########################################################################################
module "gcp_derf_user_secrets" {
  source = "../derf-deployment/gcp-derf-user-secrets"

  gcp_deployment_project_id        = local.gcp_deployment_project_id
  derf_user01_accessKeyId_AWS      = module.aws_derf_execution_users.aws_iam_access_key_id_user_01
  derf_user01_accessKeySecret_AWS  = module.aws_derf_execution_users.aws_iam_access_key_secret_user_01
  derf_user02_accessKeyId_AWS      = module.aws_derf_execution_users.aws_iam_access_key_id_user_02
  derf_user02_accessKeySecret_AWS  = module.aws_derf_execution_users.aws_iam_access_key_secret_user_02
  derf_default_accessKeyId_AWS     = module.aws_derf_execution_users.aws_iam_access_key_id_default_user
  derf_default_accessKeySecret_AWS = module.aws_derf_execution_users.aws_iam_access_key_secret_default_user 


    depends_on = [
    module.aws_derf_execution_users,
    module.gcp_bootstrapping
  ]

}

#########################################################################################
# Deploy the proxy app in GCP for executing attacks in AWS
##########################################################################################
module "gcp-aws-proxy-app" {
  source = "../derf-deployment/gcp-aws-proxy-app"

  gcp_deployment_project_id              = local.gcp_deployment_project_id
  derf_user01_accessKeyId_AWS_SMID       = module.gcp_derf_user_secrets.derf_user01_accessKeyId_AWS_SMID
  derf_user01_accessKeySecret_AWS_SMID   = module.gcp_derf_user_secrets.derf_user01_accessKeySecret_AWS_SMID
  derf_user02_accessKeyId_AWS_SMID       = module.gcp_derf_user_secrets.derf_user02_accessKeyId_AWS_SMID
  derf_user02_accessKeySecret_AWS_SMID   = module.gcp_derf_user_secrets.derf_user02_accessKeySecret_AWS_SMID
  derf_default_accessKeyId_AWS_SMID      = module.gcp_derf_user_secrets.derf_default_accessKeyId_AWS_SMID
  derf_default_accessKeySecret_AWS_SMID  = module.gcp_derf_user_secrets.derf_default_accessKeySecret_AWS_SMID


    depends_on = [
    module.aws_derf_execution_users,
    module.gcp_bootstrapping,
    module.gcp_derf_user_secrets

  ]

}



#########################################################################################
# Deploy a infrastructure to invoke the Cloud Build Trigger on first launch
##########################################################################################
module "gcp-eventarc-trigger" {
  source = "../derf-deployment/gcp-eventarc-trigger"

  gcp_deployment_project_id              = local.gcp_deployment_project_id
  google_cloudbuild_trigger_id           = module.gcp-aws-proxy-app.google_cloudbuild_trigger_id


    depends_on = [
    module.gcp_bootstrapping,
    module.gcp-aws-proxy-app

  ]

}

resource "google_project_service" "random_apis" {
  project = local.gcp_deployment_project_id
  service = "vision.googleapis.com"
  disable_on_destroy = true
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_dependent_services=true
  depends_on = [ module.gcp-eventarc-trigger ]
}

