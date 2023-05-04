######################################################################################
## DeRF Default User Permissions
######################################################################################

resource "aws_iam_policy" "create-policy" {
  name        = "cloudtrail-create"
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

resource "aws_iam_user_policy_attachment" "create-policy-attachment" {
  user      = "DeRF-Default-User"
  policy_arn = aws_iam_policy.create-policy.arn
}

######################################################################################
## DeRF Execution Users Permissions
######################################################################################

resource "aws_iam_policy" "delete-policy" {
  name        = "cloudtrail-delete"
  description = "A policy to enable the AWS Cloudtrail Trail Delete Attack"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683160702787",
      "Action": [
        "cloudtrail:DeleteTrail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}


resource "aws_iam_group_policy_attachment" "delete-policy-attachment" {
  group      = "derf-execution-users"
  policy_arn = aws_iam_policy.delete-policy.arn
}