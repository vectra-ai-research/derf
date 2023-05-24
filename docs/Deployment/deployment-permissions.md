## Deployment Permissions

### AWS
Below are the documented AWS IAM Permissions required to deploy the DeRF into a targeted AWS Account.  This policy does not take into account the permissions needed to open an AWS, or managed your credentials.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1683153705818",
      "Action": [
        "iam:AddUserToGroup",
        "iam:AttachGroupPolicy",
        "iam:AttachRolePolicy",
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateGroup",
        "iam:CreatePolicy",
        "iam:CreatePolicyVersion",
        "iam:CreateUser",
        "iam:CreateRole",
        "iam:DeleteAccessKey",
        "iam:DeleteAccountAlias",
        "iam:DeleteGroup",
        "iam:DeleteGroupPolicy",
        "iam:DeletePolicy",
        "iam:DeleteRole",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachGroupPolicy",
        "iam:DetachUserPolicy",
        "iam:GetAccessKeyLastUsed",
        "iam:GetGroup",
        "iam:GetGroupPolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetUser",
        "iam:GetUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedGroupPolicies",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupPolicies",
        "iam:ListGroups",
        "iam:ListGroupsForUser",
        "iam:ListPolicies",
        "iam:ListUserPolicies",
        "iam:ListUserTags",
        "iam:ListUsers",
        "iam:PutGroupPolicy",
        "iam:PutRolePolicy",
        "iam:PutUserPolicy",
        "iam:RemoveUserFromGroup",
        "iam:TagPolicy",
        "iam:TagUser",
        "iam:UntagPolicy",
        "iam:UntagUser",
        "iam:UpdateAccessKey",
        "iam:UpdateAccountEmailAddress",
        "iam:UpdateAccountName",
        "iam:UpdateGroup",
        "iam:UpdateUser",
        "cloudtrail:CreateTrail",
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutAccountPublicAccessBlock",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:CopyObject",
        "s3:PutBucketAcl",
        "s3:PutLifecycleConfiguration",
        "ec2:DescribeSnapshotTierStatus",
        "ec2:DescribeSnapshotTierStatus",
        "ec2:RestoreSnapshotTier",
        "ec2:DescribeSnapshots",
        "ssm:PutParameter",
        "ec2:CreateSubnet",
        "ec2:CreateSecurityGroup",
        "guardduty:CreateDetector",
        "events:PutRule",
        "events:PutTarget",
        "lambda:CreateFunction",
        "lambda:GetFunction",
        "lambda:GetPolicy",
        "lambda:AddPermission",
        "cloudtrail:CreateTrail",
        "cloudtrail:DeleteTrail",
        "kms:CreateKey",
        "kms:DeleteAlias",
        "kms:CreateAlias",
        "kms:EnableKey",
        "kms:DisableKey",
        "kms:GenerateDataKey",
        "kms:ListAliases",
        "kms:UpdateKeyDescription",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}

```


### GCP Deployment
Below are the Google Managed Roles required to deploy the DeRF into a Google Project.  It does not take into account the permissions required to create the project in the first place

- **roles/secretmanager.admin** applied at the Project-Level
    - Required to create Secrets used to store AWS Access Key Id and Secrets and assign Roles at the Secret-Level.
- **roles/cloudbuild.builds.editor** applied at the Project-Level
    - Required to deploy a Cloud Build trigger used in the deployment pipeline of the Cloud Run `aws-proxy-app`
- **roles/run.admin** applied at the Project-Level
    - Required to deploy the Cloud Run `aws-proxy-app`
- **roles/artifactregistry.admin** applied at the Project-Level
    - Required when triggering Cloud Builds to store built image artifacts
- **roles/workflows.admin** applied at the Project-Level
    - Required to deploy and invoke Google Workflows
- **roles/resourcemanager.projectIamAdmin** applied at the Project-Level
    - Required to set IAM Policy at the Project level.




