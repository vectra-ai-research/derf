## IAM

resource "aws_iam_role" "derf-ec2-role-for-ssm-access" {
  name               = "derf-ec2-role-for-ssm"
  path               = "/"
  description        = "IAM Role for EC2 instance used in DeRF Attack Techniques, specifically when attacker needs to SSM into instance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

}

resource "aws_iam_instance_profile" "derf-ec2-profile-for-ssm-access" {
  name = "maze-rendering-ec2-role"
  role = aws_iam_role.derf-ec2-role-for-ssm-access.name
}

resource "aws_iam_role_policy_attachment" "derf-ec2-policy-attachment-for-ssm" {
  role       = aws_iam_role.derf-ec2-role-for-ssm-access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "derf-ec2-policy-document-1" {
  statement {
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "ecs:DescribeTasks"
    ]
    resources = ["*"]
  }
}



resource "aws_iam_policy" "derf-ec2-policy-1" {
  name        = "derf-ec2-policy-1"
  path        = "/"
  description = "IAM policy for DeRF EC2 Instance"
  policy      = data.aws_iam_policy_document.derf-ec2-policy-document-1.json

}

resource "aws_iam_role_policy_attachment" "derf-ec2-policy-attachment" {
  role       = aws_iam_role.derf-ec2-role-for-ssm-access.name
  policy_arn = aws_iam_policy.derf-ec2-policy-1.arn
}


## EC2 Instance

resource "aws_security_group" "derf-ec2-with-ssm" {
  name        = "derf-ec2-with-ssm-sg"
  description = "Security group rules for EC2 accessible via SSM."
  vpc_id      = var.delos_web_prod_vpc.vpc_id

}

locals {
  user_data = <<EOT
#!/bin/bash
yum install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_arm64/amazon-ssm-agent.rpm
yum install -y https://s3.us-east-1.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl status amazon-ssm-agent
yum install -y bind-utils
EOT
}

data "aws_ami" "arm64" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_instance" "derf-ec2-with-ssm-enabled" {
  ami                         = data.aws_ami.arm64.id
  instance_type               = "t4g.micro"
  iam_instance_profile        = aws_iam_instance_profile.derf-ec2-profile-for-ssm-access.name
  subnet_id                   = var.delos_web_prod_vpc.private_subnet_ids[0]
  associate_public_ip_address = false
  user_data                   = local.user_data
  user_data_replace_on_change = true

  vpc_security_group_ids = [
    aws_security_group.derf-ec2-with-ssm.id
  ]

  root_block_device {
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
  }

}

