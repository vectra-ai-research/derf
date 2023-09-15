######################################################################################
## DeRF Default User and DeRF Execution User Permissions
######################################################################################
# Permissions required for the attack techniques are codified and attacked here

resource "aws_iam_policy" "policy" {
  name        = "derf-policy-01"
  description = "A policy assigned to the DeRF Default User, DeRF Execution User 01 and Execution User 02"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683160702787",
      "Action": [
        "cloudtrail:CreateTrail",
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:StartLogging",
        "cloudtrail:PutEventSelectors",
        "ec2:ModifySnapshotAttribute",
        "ec2:GetPasswordData",
        "ec2:DescribeFlowLogs",
        "ec2:DeleteFlowLogs",
        "ec2:CreateFlowLogs",
        "ec2:DescribeVpcs",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstanceCreditSpecifications",
        "ec2:StartInstances",
        "ec2:StoptInstances",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:ModifyInstanceAttribute",
        "iam:PassRole",
        "iam:CreateUser",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:ListAccessKeys",
        "iam:ListUsers",
        "iam:DeleteUser",
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:TagUser",
        "iam:UntagUser",
        "ssm:DescribeParameters",
        "ssm:GetParameter",
        "ssm:SendCommand",
        "ssm:GetCommandInvocation",
        "secretsmanager:ListSecrets",
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "policy-attachment-default-user" {
  user      = "DeRF-Default-User"
  policy_arn = aws_iam_policy.policy.arn
}



resource "aws_iam_group_policy_attachment" "delete-policy-attachment-execution-users" {
  group      = "derf-execution-users"
  policy_arn = aws_iam_policy.policy.arn
}
