variable "projectId" {
  description = "Project ID of the GCP project to create resources in"
  type = string
  default = ""
}

variable "serviceAccount" {
  description = "The Service Account which the workflow will execute as"
  type = string
  default = ""
}