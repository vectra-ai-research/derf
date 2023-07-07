data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "derf-ebs-volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 1

  tags = {
    Name = "derf-ebs-volume-to-snapshot"
  }
}

data "aws_ebs_volume" "derf-ebs-volume" {
  most_recent = true
  depends_on = [ aws_ebs_volume.derf-ebs-volume ]

}

resource "aws_ebs_snapshot" "derf-ec2_snapshot" {
  volume_id = data.aws_ebs_volume.derf-ebs-volume.id

  tags = {
    Name = "derf"
  }
}

