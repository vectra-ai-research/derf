variable "gcp_deployment_project_id" {
  description = "The ID of the project to deploy DeRF core resources"
  type        = string
}

variable "projectId" {
  description = "Project ID of the GCP project to create resources in"
  type = string
  default = ""
}
