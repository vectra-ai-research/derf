##########################################################################################
# DeRF Execution Users
##########################################################################################
module "aws_derf_execution_users" {
  source = "./modules/aws-derf-execution-users"

  aws_primary_id        = local.aws_accounts["primary"]

  providers = {
    aws = aws.primary
  }


}

##########################################################################################
# AWS Perpetual Range Deployment
##########################################################################################
module "aws_perpetual_range" {
  source = "./modules/aws-perpetual-range"

  aws_primary_id        = local.aws_accounts["primary"]
  aws_secondary_id        = local.aws_accounts["secondary"]

  providers = {
    aws.primary = aws.primary
    aws.secondary = aws.secondary

  }

  depends_on = [
    module.aws_derf_execution_users
  ]
}