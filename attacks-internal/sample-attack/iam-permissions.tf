######################################################################################
## Additional DeRF Default User Permissions 
######################################################################################

resource "aws_iam_policy" "sample-policy-1" {
  name        = "sample-policy-1"
  description = "Additional permissions to grant the DeRF Default User"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683160702787",
      "Action": [
        "service:permission"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "sample-policy-attachment" {
  user      = "DeRF-Default-User"
  policy_arn = aws_iam_policy.sample-policy-1.arn
}

######################################################################################
## Additional DeRF Execution Users Permissions
######################################################################################

resource "aws_iam_policy" "sample-policy-2" {
  name        = "sample-policy-2"
  description = "Additional permissions to grant the DeRF Default User"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683160702787",
      "Action": [
        "service:permission"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}


resource "aws_iam_group_policy_attachment" "sample-policy-attachment" {
  group      = "derf-execution-users"
  policy_arn = aws_iam_policy.sample-policy-2.arn
}