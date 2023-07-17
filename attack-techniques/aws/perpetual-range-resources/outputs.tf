output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The Id of the VPC created in the EC2 Steal Instance Credentials Attack Technique module"
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.derf-ec2-profile-for-ssm-access.name
  description = "The name of the instance profile used to attached to DeRF EC2 instances and allows for SSM access"
}

output "public_subnet_id" {
  value       = module.vpc.public_subnets[0]
  description = "The Id of the public subnet created for EC2 instances"
}

output "sg_no_inbound_id" {
  value       = aws_security_group.derf-ec2-with-ssm.id
  description = "The Id of the security group used in the DeRF with no inbound rules and all egress allowed"
}

output "iam_ec2_role_name" {
  value       = aws_iam_role.derf-ec2-role-for-ssm-access.name
  description = "The name of the role used for DeRF EC2 instances"
}

output "CloudTrailBucketName" {
  value       = aws_s3_bucket.derf-cloudtrail-bucket.id
  description = "The name of the bucket backing the DeRF CloudTrail"
}


output "TrailName" {
  value       = aws_cloudtrail.derf-test-trail.name
  description = "The name of the DeRF CloudTrail Trali"
}

