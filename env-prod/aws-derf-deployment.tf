##########################################################################################
# DeRF Execution Users
##########################################################################################
module "aws_derf_execution_users" {
  source = "../derf-deployment/aws-derf-execution-users"

  aws_primary_id          = local.aws_account_id



}
