##########################################################################################
# Privilege Escalation Attacts
##########################################################################################

module "gcp_impersonate_service_account" {
  source = "../attack-techniques/gcp/privilege-escalation/impersonate-service-accounts"

  projectId             = local.gcp_deployment_project_id
  gcp_derf_project_id   = local.gcp_derf_project_id
  derf-attacker-SA-01_member  = module.gcp-derf-execution-users.derf-attacker-SA-01_member
  derf-attacker-SA-02_member  = module.gcp-derf-execution-users.derf-attacker-SA-02_member
  workflows-to-cloudrun-service-account_member = module.gcp-aws-proxy-app.workflows-to-cloudrun-service-account_member

  providers = {
    google          = google.derf
  }

## Attacks defined in Google Worksflows rely on the underlying infrastructure to be in place to
## Work properly such as the Proxy App, Derf Execution Users and the Base GCP Project.  
  depends_on = [
    module.gcp-derf-execution-users,
    module.gcp_bootstrapping

  ]

}
