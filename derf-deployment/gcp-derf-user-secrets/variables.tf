variable "gcp_deployment_project_id" {
  description = "The ID of the project to deploy DeRF core resources"
  type        = string
}

variable "derf_user01_accessKeyId_AWS" {
  description = "The value of DeRF Execution User 01's Access Key Id"
  type        = string
}

variable "derf_user01_accessKeySecret_AWS" {
  description = "The value of DeRF Execution User 01's Access Key Secret"
  type        = string
}

variable "derf_user02_accessKeyId_AWS" {
  description = "The value of DeRF Execution User 02's Access Key Id"
  type        = string
}

variable "derf_user02_accessKeySecret_AWS" {
  description = "The value of DeRF Execution User 02's Access Key Secret"
  type        = string
}

variable "derf_default_accessKeyId_AWS" {
  description = "The value of the defautl DeRF User's Access Key ID"
  type        = string
}

variable "derf_default_accessKeySecret_AWS" {
  description = "The value of the default DeRF User's Access Key Secret"
  type        = string
}