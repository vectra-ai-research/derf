variable "projectId" {
  description = "Project ID of the GCP project to create resources in"
  type = string
  default = ""
}


variable "CloudTrailBucketName" {
  type = string
  default = ""
  description = "The name of the bucket backing the DeRF CloudTrail"
}


variable "TrailName" {
  type = string
  default = ""
  description = "The name of the DeRF CloudTrail Trali"
}
