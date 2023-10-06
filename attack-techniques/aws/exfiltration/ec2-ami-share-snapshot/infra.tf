

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 1

  tags = {
    Name = "derf-ec2-ami-share-snapshot"
  }
}

resource "aws_ebs_snapshot" "snapshot" {
  volume_id = aws_ebs_volume.volume.id
}


resource "aws_ami" "ami" {
  name                = "derf-ec2-ami-share-snapshot-ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot.snapshot.id
    volume_size = 1
  }
}
