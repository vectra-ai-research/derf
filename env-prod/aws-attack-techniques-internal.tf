##########################################################################################
# Internal Attack Modules
# Uncomment below to source a the sample internal attack module
##########################################################################################
# module "sample_attack_module" {
#   source = "../attacks-internal/discovery/sample-attack"

#   projectId          = local.gcp_deployment_project_id

#   providers = {
#     google          = google.derf
#   }