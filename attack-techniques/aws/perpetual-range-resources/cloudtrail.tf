resource "aws_cloudtrail" "derf-test-trail" {
  name                          = "derf-trail"
  s3_bucket_name                = aws_s3_bucket.derf-cloudtrail-bucket.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  depends_on = [ aws_s3_bucket_policy.derf-cloudtrail-bucket-policy ]
}

### Cloudtrail Bucket
resource "aws_s3_bucket" "derf-cloudtrail-bucket" {
  bucket_prefix        = "derf-cloudtrail-bucket-"
  force_destroy        = true
}

resource "aws_s3_bucket_policy" "derf-cloudtrail-bucket-policy" {
  bucket = aws_s3_bucket.derf-cloudtrail-bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.derf-cloudtrail-bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.derf-cloudtrail-bucket.arn}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}


resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.derf-cloudtrail-bucket.id

  rule {
    id = "cloudtrail-logs"

    expiration {
      days = 30
    }
    status = "Enabled"
  }
}