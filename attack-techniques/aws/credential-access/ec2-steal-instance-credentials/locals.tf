locals {
  instance_id = aws_instance.derf-ec2-with-ssm-enabled.id
  role_name   = aws_iam_role.derf-ec2-role-for-ssm-access.name
}