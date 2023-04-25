variable "aws_primary_id" {
  description = "The Account ID of the primary AWS Account which DeRF Resources will be deployed and attacker are executed"
  type        = string
}

variable "aws_secondary_id" {
  description = "The Account ID of the secondary AWS Account used as an 'external account' when attacks which rely on an valid external account are executed"
  type        = string
}

variable "aws_primary_profile" {
  description = "The AWS Profile used to deploy the perpetual range in the Primary Account"
  type = string
}

variable "aws_secondary_profile" {
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

variable "gcp_deployment_project_id" {
  description = "The ID of the project to deploy DeRF core resources"
  type        = string
}

variable "github_token" {
  description = "A GitHub Personal Access Token used to pull the derf-vectra-private repo and connect into GCP CloudBuild"
  type        = string
  default     = null
}

