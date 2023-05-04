######################################################################################
## DeRF Execution User Permissions
######################################################################################

resource "aws_iam_policy" "create-policy" {
  name        = "cloudtrail-delete"
  description = "A policy to enable the AWS Cloudtrail Trail Delete Attack"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683160702787",
      "Action": [
        "cloudtrail:CreateTrail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_group_policy_attachment" "cloudtrail-policy-attachment" {
  group      = "derf-execution-users"
  policy_arn = aws_iam_policy.create-policy.arn
}

######################################################################################
## DeRF Default User Permissions
######################################################################################

resource "aws_iam_policy" "create-policy" {
  name        = "cloudtrail-delete"
  description = "A policy to enable the AWS Cloudtrail Trail Delete Attack"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683160702787",
      "Action": [
        "cloudtrail:CreateTrail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_group_policy_attachment" "cloudtrail-policy-attachment" {
  group      = "derf-execution-users"
  policy_arn = aws_iam_policy.create-policy.arn
}