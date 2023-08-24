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
      lifecycle {
    create_before_destroy = false
  }

}

resource "aws_iam_instance_profile" "derf-ec2-profile-for-ssm-access" {
  name = "derf-ec2-profile-for-ssm-access"
  role = aws_iam_role.derf-ec2-role-for-ssm-access.name
    lifecycle {
    create_before_destroy = false
  }

}

resource "aws_iam_role_policy_attachment" "derf-ec2-policy-attachment-for-ssm" {
  role       = aws_iam_role.derf-ec2-role-for-ssm-access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      lifecycle {
    create_before_destroy = false
  }
}

data "aws_iam_policy_document" "derf-ec2-policy-document-1" {
  statement {
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "ec2:DescribeInstances",
      "s3:List*",
      "iam:GetAccountSummary",
      "iam:GetRoles",
      "iam:GetUsers",
      "iam:GetAccountAuthorizationDetails",
      "ec2:DescribeSnapshots",
      "cloudtrail:DescribeTrails",
      "guardduty:ListDetectors"
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