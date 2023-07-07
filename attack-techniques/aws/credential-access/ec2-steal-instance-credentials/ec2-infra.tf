## IAM

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {

    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "derf-ec2-role-for-ssm-access" {
  name               = "derf-ec2-role-for-ssm"
  path               = "/"
  description        = "IAM Role for EC2 instance used in DeRF Attack Techniques, specifically when attacker needs to SSM into instance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

}

resource "aws_iam_instance_profile" "derf-ec2-profile-for-ssm-access" {
  name = "derf-ec2-profile-for-ssm-access"
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
      "ec2:DescribeInstances"
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
  vpc_id      = module.vpc.vpc_id

  #all outbound
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
  create_before_destroy = true
  }
}

locals {
  user_data = <<EOT
#!/bin/bash
yum install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_arm64/amazon-ssm-agent.rpm
yum install -y https://s3.us-east-1.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl status amazon-ssm-agent
sudo yum install -y bind-utils
sudo yum -y install jq
EOT
}

data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "derf-ec2-with-ssm-enabled" {
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.derf-ec2-profile-for-ssm-access.name
  subnet_id                   = module.vpc.public_subnets[0]
  user_data                   = local.user_data
  user_data_replace_on_change = true
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.derf-ec2-with-ssm.id
  ]

  root_block_device {
    delete_on_termination = true
  }

    tags = {
    Name = "derf-ec2-with-ssm-enabled"
  }

}

