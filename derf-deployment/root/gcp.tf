#########################################################################################
# Ensure APIs are configured for the GCP Project
##########################################################################################
module "gcp_bootstrapping" {
  source = "../gcp-bootstrapping"

  gcp_deployment_project_id  = local.gcp_deployment_project_id

  providers = {
    google          = google.derf
  }
}
#########################################################################################
# Store AWS Access Keys and Secrets as GCP Secrets
##########################################################################################
module "gcp_derf_user_secrets" {
  source = "../gcp-derf-user-secrets"

  gcp_deployment_project_id       = local.gcp_deployment_project_id
  derf_user01_accessKeyId_AWS     = module.aws_derf_execution_users.aws_iam_access_key_id_user_01
  derf_user01_accessKeySecret_AWS = module.aws_derf_execution_users.aws_iam_access_key_secret_user_01
  derf_user02_accessKeyId_AWS     = module.aws_derf_execution_users.aws_iam_access_key_id_user_02
  derf_user02_accessKeySecret_AWS = module.aws_derf_execution_users.aws_iam_access_key_secret_user_02

  providers = {
    google          = google.derf
  }
    depends_on = [
    module.aws_derf_execution_users,
    module.gcp_bootstrapping

  ]

}

#########################################################################################
# Deploy the proxy app in GCP for executing attacks in AWS
##########################################################################################
module "gcp-aws-proxy-app" {
  source = "../gcp-aws-proxy-app"

  gcp_deployment_project_id             = local.gcp_deployment_project_id
  derf_user01_accessKeyId_AWS_SMID      = module.gcp_derf_user_secrets.derf_user01_accessKeyId_AWS_SMID
  derf_user01_accessKeySecret_AWS_SMID  = module.gcp_derf_user_secrets.derf_user01_accessKeySecret_AWS_SMID
  derf_user02_accessKeyId_AWS_SMID      = module.gcp_derf_user_secrets.derf_user02_accessKeyId_AWS_SMID
  derf_user02_accessKeySecret_AWS_SMID  = module.gcp_derf_user_secrets.derf_user02_accessKeySecret_AWS_SMID
  # github_token                          = var.github_token  

  providers = {
    google          = google.derf
  }
    depends_on = [
    module.aws_derf_execution_users,
    module.gcp_bootstrapping,
    module.gcp_derf_user_secrets

  ]

}
