# DeRF AWS Perpetual Range
The AWS perpetual range is a terraform module containing all resources required to be seeded into an AWS Account and are expected to be in place by the various Detection Workflows.  These resources include various buckets, EC2 instances, an IAM User, Lambda Function and Policy.

## Manipulating the AWS Perpetual Range
Changes or modifications to the configurations of the perpetual range are performed by detection workflows.  It is the responsibility of detection workflows to revert changes made to perpetual range components, back to their original state.


## Deploying the AWS Perpetual Range
To deploy a copy of the AWS Perpetual Range to your own Account, create a `.tfvars` file defining the variables:
- awsProfile
- awsExternalProfile
- awsAccount  
- awsExternalAccountId
- region
- pathToAWSConfig
  
Apply the terraform configuration by specifying the use of your `-var-file`

## AWS Perpetual Range - Resource Names
Upon deployment, the names of the AWS resources created are outputed per the `outputs.tf` file.  Use these values to complete your deployment specific `.tfvars` file within the `/aws-detection-workflows` and `/aws-validation-workflows` modules.