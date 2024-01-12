variable "aws_account_id" {
  description = "The Account ID of the AWS Account which DeRF Resources will be deployed and attacker are executed"
  type        = string
}


variable "gcp_deployment_project_id" {
  description = "The ID of the project to deploy DeRF core resources"
  type        = string
}

variable "gcp_derf_project_id" {
  description = "The ID of the project which attacks will execute in"
  type        = string
}
