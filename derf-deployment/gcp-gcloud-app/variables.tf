variable "gcp_deployment_project_id" {
  description = "The ID of the project to deploy DeRF core resources"
  type        = string
}

variable "aws-proxy-app-service-account_id" {
  type        = string
  description = "The ID of the service account as the Identity for the AWS Proxy App"

}