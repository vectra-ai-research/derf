##########################################################################################
# Attacks in the Discovery Category
##########################################################################################
module "aws_ec2_get_user_data" {
  source = "../aws/discovery/ec2-get-user-data"
  aws_primary_id          = local.aws_primary_id

  providers = {
    aws.primary = aws.primary
  }


}