variable "gcp_deployment_project_id" {
  description = "The ID of the project to deploy DeRF core resources"
  type        = string
}

variable "derf_user01_accessKeyId_AWS_SMID" {
  description = "The Secret Manager Id for the secret: DeRF Execution User 01 Access Key ID"
  type        = string
}

variable "derf_user01_accessKeySecret_AWS_SMID" {
  description = "The Secret Manager Id for the secret: DeRF Execution User 01 Access Key Secret"
  type        = string
}

variable "derf_user02_accessKeyId_AWS_SMID" {
  description = "The Secret Manager Id for the secret:  DeRF Execution User 02 Access Key ID"
  type        = string  
}

variable "derf_user02_accessKeySecret_AWS_SMID" {
  description = "The Secret Manager Id for the secret: DeRF Execution User 02 Access Key Secret"
  type        = string
}

# variable "github_token" {
#   description = "A GitHub Personal Access Token used to pull the derf-vectra-private repo and connect into GCP CloudBuild"
#   type        = string
#   default     = null
# }