variable "gcp_deployment_project_id" {
  description = "The ID of the GCP Project to deploy DeRF core resources"
  type        = string
}

variable "gcp_derf_project_id" {
  description = "The ID of the GCP Project which attacks will execute in"
  type        = string
}
