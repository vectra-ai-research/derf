data "aws_ebs_volume" "derf-ebs-volume" {
  most_recent = true


}

resource "aws_ebs_snapshot" "derf-ec2_snapshot" {
  volume_id = data.aws_ebs_volume.derf-ebs-volume.id

  tags = {
    Name = "derf"
  }
}

