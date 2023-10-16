data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}


resource "aws_ami_copy" "derf-amazon-2-copy" {
  name              = "tderf-amazon-2-copy"
  description       = "A copy of the mos recent amazon linux"
  source_ami_id     = data.aws_ami.amazon-2.id
  source_ami_region = data.aws_region.current.name

  tags = {
    Name = "derf-ami-share-copy"
  }
}