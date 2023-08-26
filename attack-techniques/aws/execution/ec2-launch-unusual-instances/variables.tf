variable "projectId" {
  description = "Project ID of the GCP project to create resources in"
  type = string
  default = ""
}

variable "instance_id" {
  type = string
  default = ""
  description = "The Id of EC2 instance used in multiple DeRF AWS Attack techniques"
}


variable "vpc_id" {
  type = string
  default = ""
  description = "The Id of the VPC created in the EC2 Steal Instance Credentials Attack Technique module"
}

variable "instance_profile_name" {
  type = string
  default = ""
  description = "The name of the instance profile used to attached to DeRF EC2 instances and allows for SSM access"
}

variable "public_subnet_id" {
  type = string
  default = ""
  description = "The Id of the public subnet created for EC2 instances"
}

variable "sg_no_inbound_id" {
  type = string
  default = ""
  description = "The Id of the security group used in the DeRF with no inbound rules and all egress allowed"
}

variable "iam_ec2_role_name" {
  type = string
  default = ""
  description = "The name of the role used for DeRF EC2 instances"
}