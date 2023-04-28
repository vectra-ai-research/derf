##########################################################################################
# DeRF Execution Users
##########################################################################################
module "aws_derf_execution_users" {
  source = "../derf-deployment/aws-derf-execution-users"

  aws_primary_id          = local.aws_primary_id

  providers = {
    aws.primary = aws.primary
  }


}

##########################################################################################
# AWS Perpetual Range Deployment
##########################################################################################
module "aws_perpetual_range" {
  source = "../derf-deployment/aws-perpetual-range"

  aws_primary_id          = local.aws_primary_id
  aws_secondary_id        = local.aws_secondary_id

  providers = {
    aws.primary = aws.primary

  }

  depends_on = [
    module.aws_derf_execution_users
  ]
}