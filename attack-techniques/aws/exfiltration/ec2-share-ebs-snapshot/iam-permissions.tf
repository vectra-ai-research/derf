######################################################################################
## DeRF Default and Execution User Permissions
######################################################################################

resource "aws_iam_policy" "ModifySnapshotAttribute" {
  name        = "modify-snapshot-attribute"
  description = "A policy to allow for the modification of the attributes associated with EBS Volume snapshots"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683160702787",
      "Action": [
        "ec2:ModifySnapshotAttribute"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "user-policy-attachment" {
  user      = "DeRF-Default-User"
  policy_arn = aws_iam_policy.ModifySnapshotAttribute.arn
}


resource "aws_iam_group_policy_attachment" "group-policy-attachment" {
  group      = "derf-execution-users"
  policy_arn = aws_iam_policy.ModifySnapshotAttribute.arn
}