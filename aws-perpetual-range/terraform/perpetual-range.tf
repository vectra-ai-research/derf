### IAM Resources

resource "aws_iam_group" "derf-mock-group" {
  name = "derf-mock-group"
  path = "/"
}


resource "aws_iam_role" "derf-mock-role" {
  name = "derf-mock-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": "arn:aws:iam::${var.awsAccountId}:root",
          "Service": "glue.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
})

}

resource "aws_iam_user" "DeRF-perpetual-range-user" {
  name = "DeRF-perpetual-range-user"
  path = "/"

  tags = {
    tag-key = "derf-mock-user"
  }
}

resource "aws_iam_role" "derf-lambda-execution-role" {
  name = "derf-lambda-execution-role"


  inline_policy {
    name = "derf-lambda-execution-role-policy"
    }

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
})

  tags = {
    Name        = "derf"
  }
}

resource "aws_iam_policy" "derf-lambda-execution-role-policy" {
  name = "derf-lambda-execution-role-policy"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1632342108306",
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1632342367284",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:us-east-1:553429306996:*"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role       = aws_iam_role.derf-lambda-execution-role.name
  policy_arn = aws_iam_policy.derf-lambda-execution-role-policy.arn
}


##Role assumed by AWS EventBridge to invoke Lambda Functions in Lambda Hijacking
resource "aws_iam_role" "derf-eventBridge-InvokeFunction-role" {
  name = "derf-eventBridge-InvokeFunction-role"

  inline_policy {
    name = "derf-eventBridge-InvokeFunction-policy"
    }

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
})

  tags = {
    Name        = "derf"
  }
}

resource "aws_iam_policy" "derf-eventBridge-InvokeFunction-policy" {
  name = "derf-eventBridge-InvokeFunction-policy"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InvokeAllLambdaFunctions",
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "attach-eventBridgepolicy" {
  role       = aws_iam_role.derf-eventBridge-InvokeFunction-role.name
  policy_arn = aws_iam_policy.derf-eventBridge-InvokeFunction-policy.arn
}

### EC2 Instance Profile and Role


resource "aws_iam_role" "derf-ec2-role" {
  name = "derf-ec2-role"


  inline_policy {
    name = "derf-ec2-instance-profile-policy"
    }

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
})

  tags = {
    Name        = "derf"
  }
}

resource "aws_iam_instance_profile" "derf-ec2-instance-profile" {
  name = "derf-ec2-instance-profile"
  role = aws_iam_role.derf-ec2-role.name
}

resource "aws_iam_policy" "derf-ec2-instance-profile-policy" {
  name = "derf-ec2-instance-profile-policy"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2Actions",
      "Action": ["ec2:List*","ec2:Describe*","ec2:RunInstances","ec2:StopInstances","ec2:CreateTags","ec2:TerminateInstances"],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}


resource "aws_iam_role_policy_attachment" "derf-ec2-role-for-ssm" {
role       = aws_iam_role.derf-ec2-role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "derf-ec2-ssm-policy" {
role       = aws_iam_role.derf-ec2-role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "derf-ec2-ssm-logAccess" {
role       = aws_iam_role.derf-ec2-role.name
policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "derf-ec2-ssm-inline_policy" {
role       = aws_iam_role.derf-ec2-role.name
policy_arn = aws_iam_policy.derf-ec2-instance-profile-policy.arn
}

## ECS Task Definitions

resource "aws_ecs_task_definition" "service1" {
  family = "service1"
  container_definitions = jsonencode([
    {
      name      = "first1"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

resource "aws_ecs_task_definition" "service2" {
  family = "service2"
  container_definitions = jsonencode([
    {
      name      = "first2"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}


## Lambda Hijacking Resources

resource "aws_lambda_function" "derf-lambda-hijacking" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  s3_bucket     = aws_s3_object.lambda_code.bucket
  s3_key        = aws_s3_object.lambda_code.key
  function_name = "derf-Backdoor-SecurityGroups"
  role          = aws_iam_role.derf-lambda-execution-role.arn
  handler       = "backdoor-lambda-secGroups.lambda_handler"
  runtime       = "python3.9"

  depends_on = [
    aws_iam_role.derf-lambda-execution-role,
    aws_iam_policy.derf-lambda-execution-role-policy,
    aws_s3_bucket.derf-lambda-hijacking-code-bucket,
    aws_s3_object.lambda_code
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.derf-lambda-hijacking.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:us-east-1:553429306996:rule/*"
}

## S3 Buckets

### Lambda Code Bucket

resource "aws_s3_bucket" "derf-lambda-hijacking-code-bucket" {
  bucket_prefix = "derf-lambda-hijacking-code-"

  tags = {
    Name        = "derf"
  }
}

resource "aws_s3_bucket_public_access_block" "derf-lambda-hijacking-code-bucket-pab" {
  bucket = aws_s3_bucket.derf-lambda-hijacking-code-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.derf-lambda-hijacking-code-bucket.bucket
  key    = "backdoor-lambda-secGroups.py.zip"
  source = "../lambda-code/backdoor-lambda-secGroups.py.zip"
}


### Ransomed Bucket

resource "aws_s3_bucket" "derf-ransomed-bucket" {
  bucket_prefix = "derf-ransomed-bucket-"

  tags = {
    Name        = "derf"
  }
}

resource "aws_s3_object" "n01_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n01.txt"
  source = "./s3-files/sample_n01.txt"
}

resource "aws_s3_object" "n02_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n02.txt"
  source = "./s3-files/sample_n02.txt"
}

resource "aws_s3_object" "n03_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n03.txt"
  source = "./s3-files/sample_n03.txt"
}

resource "aws_s3_object" "n04_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n04.txt"
  source = "./s3-files/sample_n04.txt"
}

resource "aws_s3_object" "n05_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n05.txt"
  source = "./s3-files/sample_n05.txt"
}

resource "aws_s3_object" "n06_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n06.txt"
  source = "./s3-files/sample_n06.txt"
}

resource "aws_s3_object" "n07_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n07.txt"
  source = "./s3-files/sample_n07.txt"
}

resource "aws_s3_object" "n08_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n08.txt"
  source = "./s3-files/sample_n08.txt"
}

resource "aws_s3_object" "n09_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n09.txt"
  source = "./s3-files/sample_n09.txt"
}

resource "aws_s3_object" "n10_object" {
  bucket = aws_s3_bucket.derf-ransomed-bucket.bucket
  key    = "sample_n10.txt"
  source = "./s3-files/sample_n10.txt"
}


### Source Bucket

resource "aws_s3_bucket" "derf-source-bucket" {
  bucket_prefix = "derf-source-bucket-"

  tags = {
    Name        = "derf"
  }
}

resource "aws_s3_bucket_public_access_block" "derf-source-bucket-pab" {
  bucket = aws_s3_bucket.derf-source-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "sample_object" {
  bucket = aws_s3_bucket.derf-source-bucket.bucket
  key    = "sample_n01.txt"
  source = "./s3-files/sample_n01.txt"
}


### Desintation Bucket

resource "aws_s3_bucket" "derf-destination-bucket" {
  bucket_prefix = "derf-destination-bucket-"

  tags = {
    Name        = "derf"
  }
}

resource "aws_s3_bucket_public_access_block" "derf-destination-bucket-pab" {
  bucket = aws_s3_bucket.derf-destination-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

### External Bucket

resource "aws_s3_bucket" "derf-external-bucket" {
  bucket_prefix = "derf-external-bucket-"
  provider = aws.external

  tags = {
    Name        = "derf"
  }
}

resource "aws_s3_bucket_public_access_block" "derf-external-bucket-pab" {
  bucket = aws_s3_bucket.derf-external-bucket.id
  provider = aws.external

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

## Network Components

resource "aws_vpc" "derf-vpc" {
  cidr_block       = "10.0.1.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "derf-vpc"
  }
}

resource "aws_subnet" "derf-subnet" {
  vpc_id     = aws_vpc.derf-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "derf-subnet"
  }
}

resource "aws_security_group" "derf-security-group" {
  name        = "derf created security group"
  description = "Allow all egress with no ingress rules"
  vpc_id      = aws_vpc.derf-vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "derf"
  }
}

resource "aws_security_group" "derf-security-group02" {
  name        = "derf-created-security-group"
  description = "Allow all egress with no ingress rules"
  vpc_id      = aws_vpc.derf-vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "derf-02"
  }
}

## EC2 Instances

# https://www.terraform.io/docs/providers/aws/d/ami.html#attributes-reference
data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  # Describe filters
  # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeImages.html
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "template_file" "startup" {
 template = file("./install-scripts/ssm-agent-installer.sh")
}

resource "aws_instance" "derf-base-ec2" {
  ami                     = "ami-090fa75af13c156b4"
  instance_type           = "t2.micro"
  iam_instance_profile    = aws_iam_instance_profile.derf-ec2-instance-profile.name
  subnet_id               = aws_subnet.derf-subnet.id   
  vpc_security_group_ids  = [aws_security_group.derf-security-group.id]

  ebs_block_device {
    delete_on_termination = true
    device_name = "/dev/sdh"
    volume_type           = "gp2"
    volume_size           = 20
    tags = {
      Name = "derf-base-ec2-ebs-volume"
      }
    }

  tags = {
    Name = "derf-base-ec2"
  }
  user_data       = <<-EOF
              #!/bin/bash
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              EOF

}

data "aws_ebs_volume" "derf-ebs-volume" {
  most_recent = true

  filter {
    name   = "attachment.instance-id"
    values = ["${aws_instance.derf-base-ec2.id}"]
  }
  depends_on = [
    aws_instance.derf-base-ec2
  ]
}

resource "aws_ebs_snapshot" "derf-base-ec2_snapshot" {
  volume_id = data.aws_ebs_volume.derf-ebs-volume.id

  tags = {
    Name = "derf-base-ec2-snapshot"
  }
  depends_on = [
    data.aws_ebs_volume.derf-ebs-volume
  ]
}

## ECR Repo

resource "aws_ecr_repository" "derf-ecr-repo" {
  name                 = "derf-ecr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ssm_parameter" "derf-param-1" {
  name  = "derf-param-1"
  type  = "String"
  value = "secret-string-1"
}

resource "aws_ssm_parameter" "derf-param-2" {
  name  = "derf-param-2"
  type  = "String"
  value = "secret-string-2"
}

resource "aws_ssm_parameter" "derf-param-3" {
  name  = "derf-param-3"
  type  = "String"
  value = "secret-string-3"
}

### KMS Key

resource "aws_kms_key" "derf-external-ransomware-key" {
  description              = "Key used for Ransomware Detection residing in the secondardy AWS Account"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  deletion_window_in_days  = 30
  provider = aws.external
  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM users from main and secondard AWS Accounts to operate on this key",
            "Effect": "Allow",
            "Principal": { 
                "AWS": [ 
                  "${var.awsAccountId}",
                  "${var.awsExternalAccountId}" 
                ]
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
})
}

resource "aws_kms_alias" "derf-external-ransomware-key" {
  name          = "alias/derf-external-ransomware-key"
  target_key_id = aws_kms_key.derf-external-ransomware-key.key_id
  provider = aws.external
}

## Cloud Trail

data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "derf-test-trail" {
  name                          = "derf-test-trail"
  s3_bucket_name                = aws_s3_bucket.derf-cloudtrail-bucket.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
}
