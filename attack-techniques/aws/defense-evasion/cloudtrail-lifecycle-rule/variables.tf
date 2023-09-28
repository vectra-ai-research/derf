variable "projectId" {
  description = "Project ID of the GCP project to create resources in"
  type = string
  default = ""
}

variable "CloudTrailBucketName" {
  description = "The name of the bucket backing the DeRF CloudTrail"
  type = string
  default = ""
}

