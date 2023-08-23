## EC2 Instance

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

resource "aws_instance" "derf-ec2-execute-discovery-commands" {
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = "t3.micro"
  iam_instance_profile        = var.instance_profile_name
  subnet_id                   = var.public_subnet_id
  user_data                   = local.user_data
  user_data_replace_on_change = true
  associate_public_ip_address = true

  vpc_security_group_ids = [
    var.sg_no_inbound_id
  ]

  root_block_device {
    delete_on_termination = true
  }

    tags = {
    Name = "derf-ec2-execute-discovery-commands"
  }

}

