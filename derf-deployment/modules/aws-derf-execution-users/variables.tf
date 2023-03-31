variable "User01" {
  description = "The name of the DeRF Execution User01"
  type        = string
  default   = "DeRF-Execution-User01"
}

variable "User02" {
  description = "The name of the DeRF Execution User02"
  type        = string
  default   = "DeRF-Execution-User02"
}

variable "aws_primary_id" {
  description = "The Account ID of the primary AWS Account which DeRF Resources will be deployed and attacker are executed"
  type        = string
  default     = null
}