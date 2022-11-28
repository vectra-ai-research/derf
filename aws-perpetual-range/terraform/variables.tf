variable "awsAccountId" {
  description = "The Id of the AWS Account which these detections execute in"
  type = string
}

variable "awsProfile" {
  description = "The AWS Profile used to deploy the perpetual range"
  type = string
}

variable "awsExternalAccountId" {
  description = "A secondardy AWS Account to create 'external' resources in and 'exfiltrate' data to"
  type = string
}

variable "awsExternalProfile" {
  description = "The AWS Profile used to authenticate to the secondardy AWS Account"
  type = string
}

variable "region" {
  description = "The AWS Region to deploy resources unless noted otherwsise"
  type = string
}

variable "pathToAWSConfig" {
  description = "Full local path to AWS .config file allowing terraform to file your profile configurations"
  type = string
}


