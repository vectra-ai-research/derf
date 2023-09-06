## EC2 quota increase. Uncomment out if you want to actually create the the P2.xlarge instances in this module.

# resource "aws_servicequotas_service_quota" "p2_instances" {
#   quota_code   = "L-7212CCBC"
#   service_code = "ec2"
#   value        = 10
#   lifecycle {
#         ignore_changes = all
#     }
# }