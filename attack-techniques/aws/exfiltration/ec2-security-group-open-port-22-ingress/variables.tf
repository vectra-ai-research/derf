variable "projectId" {
  description = "Project ID of the GCP project to create resources in"
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = ""
  description = "The Id of the VPC created in the EC2 Steal Instance Credentials Attack Technique module"
}

