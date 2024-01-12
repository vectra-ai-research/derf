variable "projectId" {
  description = "Project ID of the GCP project to deploy Cloud Workflows"
  type = string
  default = ""
}

variable "gcp_derf_project_id" {
  description = "The ID of the GCP Project which attacks will execute in"
  type        = string
}
