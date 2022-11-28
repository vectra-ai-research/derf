## IAM Outputs

output "manipulatedIAMUser" {
  value       = aws_iam_user.DeRF-perpetual-range-user.name
  description = "The NAME of the IAM User seeded in the perpetual range"
}

output "lambdaRoleName" {
  value       = aws_iam_role.derf-lambda-execution-role.name
  description = "The NAME of the IAM Role attached to the Lambda Function, seeded in the perpetual range"
}

output "lambdaRolePolicyName" {
  value       = aws_iam_policy.derf-lambda-execution-role-policy.name
  description = "The NAME of the IAM Policy attached to the Lambda Role, seeded in the perpetual range"
}

output "eventBridgeInvokeFunctionRole1" {
  value       = aws_iam_role.derf-eventBridge-InvokeFunction-role.name
  description = "The NAME of the IAM Role which Event Bridge uses to invoke Lambda Functions in perpetual range"
}

output "iamMockGroupName"{
  value       = aws_iam_group.derf-mock-group.name
  description = "The NAME of the IAM Group created in the the perpectual range in order to be manipulated by DeRF workflows" 

}

output "iamMockGroupArn"{
  value       = aws_iam_group.derf-mock-group.arn
  description = "The ARN of the IAM Group created in the the perpectual range in order to be manipulated by DeRF workflows" 

}

output "iamMockRoleArn"{
  value       = aws_iam_role.derf-mock-role.arn
  description = "The ARN of the IAM Role created in the the perpectual range in order to be manipulated by DeRF workflows" 

}

output "iamMockRoleName"{
  value       = aws_iam_role.derf-mock-role.name
  description = "The NAME of the IAM Role created in the the perpectual range in order to be manipulated by DeRF workflows" 

}

output ec2InstanceProfileName {
  value = aws_iam_instance_profile.derf-ec2-instance-profile.name
  description = "The NAME of the EC2 Instance profile used in the perpetual range"
}


##Lambda Outputs


output "lambdaFunctionName1" {
  value       = aws_lambda_function.derf-lambda-hijacking.function_name
  description = "The NAME of a Lambda Function required to be seeded in the perpetual range"
}

## Bucket Outputs

output "lambdaCodeBucket" {
  value       = aws_s3_bucket.derf-lambda-hijacking-code-bucket.bucket
  description = "The NAME of the Bucket where Lambda Function code is stored for used in the perpetual range"
}

output "lambdaCodeObjectBase1" {
  value       = aws_s3_object.lambda_code.key
  description = "S3 Object where Lambda Code is stored for inital version of a Lambda Function"
}

output "ransomedBucket" {
  value       = aws_s3_bucket.derf-ransomed-bucket.bucket
  description = "The NAME of the S3 Bucket used for Ransomware detection"
}

output "sourceBucket" {
  value       = aws_s3_bucket.derf-source-bucket.bucket
  description = "The NAME of the S3 Bucket used to stage objects"
}

output "destinationBucket" {
  value       = aws_s3_bucket.derf-destination-bucket.bucket
  description = "The NAME of the S3 Bucket used to move S3 objects to"
}

output "externalBucket" {
  value       = aws_s3_bucket.derf-external-bucket.bucket
  description = "Name of the S3 Bucket in the secondary AWS Account which objects will be exfiltrated to"
}

output "cloudtrailBucketName" {
  value       = aws_s3_bucket.derf-cloudtrail-bucket.bucket
  description = "The NAME of the S3 Bucket used to store cloudtrail logs"
}


### Network Outputs


output "subnetId" {
  value       = aws_subnet.derf-subnet.id
  description = "A subnet in the derf-vpc, seeded in an AWS Account as a part of the perpetual range"
}

output "securityGroupId" {
  value       = aws_security_group.derf-security-group.id
  description = "Security Group seeded into the AWS Account and attached to the derf-vpc"
}

output "securityGroupId2" {
  value       = aws_security_group.derf-security-group02.id
  description = "The Id of the second Security Group seeded into the AWS Account and attached to the derf-vpc. This security group is not attached to any EC2 instance and can have its rules modified without impact"
}


## EC2 Outputs

output "instanceId" {
  value       = aws_instance.derf-base-ec2.id
  description = "The Id of the AWS EC2 Instance seeded into an Account which will be used during detections"
}

output EBSSnapshotId {
  value       = aws_ebs_snapshot.derf-base-ec2_snapshot.id
  description = "The ID of the snapshot seeded into the AWS perpetual range"
}

## KMS Key Outputs

output "kmsExternalRansomwareKeyId" {
  value       = aws_kms_key.derf-external-ransomware-key.id
  description = "ID of the KMS key used in Ransomware Detections, residing in the secondardy AWS Account"
}

output "kmsExternalRansomwareKeyARN" {
  value       = aws_kms_key.derf-external-ransomware-key.arn
  description = "The ARN of the KMS key used in Ransomware Detections, residing in the secondardy AWS Account"
}


## Misc Outpits

output "cloudtrailName" {
  value       = aws_cloudtrail.derf-test-trail.arn
  description = "ARN of the Cloudtrail trail manipulated in DeRF detections"
}

output "ecrRepoName" {
  value       = aws_ecr_repository.derf-ecr-repo.name
  description = "The NAME of the ECR Repo seeded into the AWS Account for the perpetual range"
}

output derfParam1 {
  value       = aws_ssm_parameter.derf-param-1.name
  description = "The NAME of SSM parameter 1 maintianed in the perpetual range"
}

output derfParam2 {
  value       = aws_ssm_parameter.derf-param-2.name
  description = "The NAME of SSM parameter 2 maintianed in the perpetual range"
}

output derfParam3 {
  value       = aws_ssm_parameter.derf-param-3.name
  description = "The NAME of SSM parameter 3 maintianed in the perpetual range"
}
