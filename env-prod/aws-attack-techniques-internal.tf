##########################################################################################
# Internal Attack Modules
# Uncomment below to source a the sample internal attack module
##########################################################################################
# module "sample_attack_module" {
#   source = "../attacks-internal/discovery/sample-attack"

#   projectId          = local.gcp_deployment_project_id

#     depends_on = [
#     module.aws_derf_execution_users,
#     module.gcp_bootstrapping,
#     module.gcp-aws-proxy-app,
#     module.gcp_derf_user_secrets
#   ]

# }