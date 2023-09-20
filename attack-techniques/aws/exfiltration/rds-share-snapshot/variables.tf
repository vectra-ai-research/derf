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

variable "sg_no_inbound_id" {
  type = string
  default = ""
  description = "The Id of the security group used in the DeRF with no inbound rules and all egress allowed"
}

variable "database_subnet_name" {
  type = string
  default = ""
  description = "The name of the database subnet associated with the perpetual range VPC created for the DeRF - used for RDS attack techniques"
}
