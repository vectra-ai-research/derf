variable "gcp_derf_project_id" {
  description = "The ID of the GCP Project which attacks will execute in"
  type        = string
}

variable "project_id" {
  description = "Project where the dataset and table are created."
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = true
}