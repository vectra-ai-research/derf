##########################################################################################
# Common Core Modules
##########################################################################################
module "aws_permissions_required" {
  source = "../attack-techniques/aws/permissions-required"

}

##deployment of commonly used resources such as VPCs, Security Groups and Instance Profiles
module "aws_perpetual_range_resources" {
  source = "../attack-techniques/aws/perpetual-range-resources"

}

##########################################################################################
# Attacks in the Credential Access
##########################################################################################

module "aws_ssm_retrieve_securestring_parameter" {
  source = "../attack-techniques/aws/credential-access/ssm-retrieve-securestring-parameters"

  projectId             = local.gcp_deployment_project_id

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

module "aws_ec2_steal_instance_credentials" {
  source = "../attack-techniques/aws/credential-access/ec2-steal-instance-credentials"

  projectId          = local.gcp_deployment_project_id
  vpc_id                = module.aws_perpetual_range_resources.vpc_id
  instance_profile_name = module.aws_perpetual_range_resources.instance_profile_name
  public_subnet_id      = module.aws_perpetual_range_resources.public_subnet_id
  sg_no_inbound_id      = module.aws_perpetual_range_resources.sg_no_inbound_id
  iam_ec2_role_name     = module.aws_perpetual_range_resources.iam_ec2_role_name

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

module "aws_ec2_get_password_data" {
  source = "../attack-techniques/aws/credential-access/ec2-get-password-data"

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

module "aws_secretsmanager_retrieve_secrets" {
  source = "../attack-techniques/aws/credential-access/secretsmanager-retrieve-secrets"

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


##########################################################################################
# Attacks in the Execution Category
##########################################################################################

module "aws_ec2_modify_user_data" {
  source = "../attack-techniques/aws/execution/ec2-modify-user-data"

  projectId          = local.gcp_deployment_project_id
  vpc_id                = module.aws_perpetual_range_resources.vpc_id
  instance_profile_name = module.aws_perpetual_range_resources.instance_profile_name
  public_subnet_id      = module.aws_perpetual_range_resources.public_subnet_id
  sg_no_inbound_id      = module.aws_perpetual_range_resources.sg_no_inbound_id
  iam_ec2_role_name     = module.aws_perpetual_range_resources.iam_ec2_role_name

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
    module.gcp_derf_user_secrets,
    module.aws_permissions_required
  ]

}


##########################################################################################
# Attacks in the Defense Evasion Category
##########################################################################################
module "aws_cloudtrail_trail_delete" {
  source = "../attack-techniques/aws/defense-evasion/cloudtrail-delete"

  projectId            = local.gcp_deployment_project_id
  CloudTrailBucketName = module.aws_perpetual_range_resources.CloudTrailBucketName
  TrailName            = module.aws_perpetual_range_resources.TrailName

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

module "aws_cloudtrail_trail_stop_logging" {
  source = "../attack-techniques/aws/defense-evasion/cloudtrail-stop"

  projectId            = local.gcp_deployment_project_id
  TrailName            = module.aws_perpetual_range_resources.TrailName

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

module "aws_cloudtrail_event_selectors" {
  source = "../attack-techniques/aws/defense-evasion/cloudtrail-event-selectors"

  projectId            = local.gcp_deployment_project_id
  TrailName            = module.aws_perpetual_range_resources.TrailName

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

module "aws_vpc_remove_flow_logs" {
  source = "../attack-techniques/aws/defense-evasion/vpc-remove-flow-logs"

  projectId          = local.gcp_deployment_project_id
  vpc_id                = module.aws_perpetual_range_resources.vpc_id

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


module "aws_organizations_leave" {
  source = "../attack-techniques/aws/defense-evasion/organizations-leave"

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

##########################################################################################
# Attacks in the Exfiltration
##########################################################################################
module "aws_ec2_share_ebs_snapshot" {
  source = "../attack-techniques/aws/exfiltration/ec2-share-ebs-snapshot"

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

##########################################################################################
# Attacks in the Initial Access Category
##########################################################################################

module "aws_console_login_without_mfa" {
  source = "../attack-techniques/aws/initial-access/console-login-without-mfa"
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