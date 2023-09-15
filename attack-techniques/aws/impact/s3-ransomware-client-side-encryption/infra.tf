data "aws_region" "current" {}

### Ransomed Bucket

resource "aws_s3_bucket" "derf-ransomed-bucket-clientside-encryption" {
  bucket_prefix = "derf-ransomed-bucket-clientside-encryption-"
  force_destroy = true
  region = data.aws_region.current

  tags = {
    Name        = "derf"
  }
}

resource "aws_s3_object" "n11_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n11.csv"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n11.csv"
}

resource "aws_s3_object" "n02_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n02.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n02.txt"
}

resource "aws_s3_object" "n03_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n03.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n03.txt"
}

resource "aws_s3_object" "n04_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n04.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n04.txt"
}

resource "aws_s3_object" "n05_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n05.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n05.txt"
}

resource "aws_s3_object" "n06_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n06.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n06.txt"
}

resource "aws_s3_object" "n07_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n07.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n07.txt"
}

resource "aws_s3_object" "n08_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n08.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n08.txt"
}

resource "aws_s3_object" "n09_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n09.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/s3-objects/sample_n09.txt"
}

resource "aws_s3_object" "n10_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket-clientside-encryption.bucket
  key    = "sample_n10.txt"
  source = "../attack-techniques/aws/impact/s3-ransomware-client-side-encryption/s3-objects/sample_n10.txt"
}


