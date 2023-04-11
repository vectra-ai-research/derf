variable "aws_primary_id" {
  description = "The Account ID of the primary AWS Account which DeRF Resources will be deployed and attacker are executed"
  type        = string
}

variable "aws_secondary_id" {
  description = "The Account ID of the secondary AWS Account used as an 'external account' when attacks which rely on an valid external account are executed"
  type        = string
}




