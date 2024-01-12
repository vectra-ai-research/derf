#########################################################################################
# Common Core Modules
##########################################################################################
  

module "gcp_impersonate_attacker_sa" {
  source = "../attack-techniques/gcp/impersonate-attacker-sa"

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

module "gcp_perpetual_range_resources" {
  source = "../attack-techniques/gcp/perpetual-range-resources"

  gcp_derf_project_id   = local.gcp_derf_project_id
  project_id            = local.gcp_derf_project_id

  providers = {
    google       = google.target
  }

## Attacks defined in Google Worksflows rely on the underlying infrastructure to be in place to
## Work properly such as the Proxy App, Derf Execution Users and the Base GCP Project.  
  depends_on = [
    module.gcp-derf-execution-users,
    module.gcp_bootstrapping

  ]

}

##########################################################################################
# Privilege Escalation Attacks
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

##########################################################################################
# Exfiltration Attacks
##########################################################################################

module "gcp_share_compute_disk" {
  source = "../attack-techniques/gcp/exfiltration/share-compute-disk"

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

module "gcp_bq_data_exfiltration_via_job_toc" {
  source = "../attack-techniques/gcp/exfiltration/bq-data-exfiltration-via-job-toc"

  projectId             = local.gcp_deployment_project_id
  gcp_derf_project_id   = local.gcp_derf_project_id
  
  providers = {
    google       = google.derf
  }

## Attacks defined in Google Worksflows rely on the underlying infrastructure to be in place to
## Work properly such as the Proxy App, Derf Execution Users and the Base GCP Project.  
  depends_on = [
    module.gcp-derf-execution-users,
    module.gcp_bootstrapping

  ]

}

##########################################################################################
# Persistence Attacks
##########################################################################################

module "gcp_backdoor_iam_service_account" {
  source = "../attack-techniques/gcp/persistence/backdoor-service-account"

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