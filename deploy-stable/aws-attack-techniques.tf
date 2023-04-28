##########################################################################################
# Attacks in the Discovery Category
##########################################################################################
module "aws_ec2_get_user_data" {
  source = "../attack-techniques/aws/discovery/ec2-get-user-data"

  projectId          = local.gcp_deployment_project_id

  providers = {
    google          = google.derf
  }

## Attacks defined in Google Worksflows rely on the underlying infrastructure to be in place to
## Work properly such as the Proxy App, Derf Execution Users and the Base GCP Project.  
  depends_on = [
    module.aws_derf_execution_users,
    module.gcp_bootstrapping,
    module.gcp-aws-proxy-app,
    module.gcp_derf_user_secrets
  ]

}