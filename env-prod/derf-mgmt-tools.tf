##########################################################################################
# DeRF Mgmt Tool Modules
##########################################################################################

module "derf_management_aws_user_provisioning_tool" {
  source = "../mgmt-tools/user-provisioning-tool"

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
    module.gcp_derf_user_secrets,
    module.aws_permissions_required
  ]

}

module "derf_management_aws_user_deprovisioning_tool" {
  source = "../mgmt-tools/user-deprovisioning-tool"

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
    module.gcp_derf_user_secrets,
    module.aws_permissions_required
  ]

}

