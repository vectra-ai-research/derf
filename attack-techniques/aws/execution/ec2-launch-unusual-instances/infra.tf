## EC2 quota increase. This can take several days to approve.

resource "aws_servicequotas_service_quota" "p2_instances" {
  quota_code   = "L-7212CCBC"
  service_code = "ec2"
  value        = 10
}