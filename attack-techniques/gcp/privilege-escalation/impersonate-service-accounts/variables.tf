variable "projectId" {
  description = "Project ID of the GCP project to deploy Cloud Workflows"
  type = string
  default = ""
}

variable "gcp_derf_project_id" {
  description = "The ID of the GCP Project which attacks will execute in"
  type        = string
}

variable "workflows-to-cloudrun-service-account_member" {
  type        = string
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions"
}

variable "derf-attacker-SA-01_member" {
  type        = string
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions."

}

variable "derf-attacker-SA-02_member" {
  type        = string
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions."

}