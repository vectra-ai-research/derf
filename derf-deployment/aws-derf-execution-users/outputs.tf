output "aws_iam_access_key_id_user_01" {
  value       = aws_iam_access_key.derf_execution_user_01_key.id
  description = "The Id of DeRF Execution User 01 Access Key"
  sensitive   = true
}

output "aws_iam_access_key_secret_user_01" {
  value       = aws_iam_access_key.derf_execution_user_01_key.secret
  description = "The SECRET of DeRF Execution User 01 Access Key"
  sensitive   = true
}

output "aws_iam_access_key_id_user_02" {
  value       = aws_iam_access_key.derf_execution_user_02_key.id
  description = "The Id of DeRF Execution User 01 Access Key"
}

output "aws_iam_access_key_secret_user_02" {
  value       = aws_iam_access_key.derf_execution_user_02_key.secret
  description = "The SECRET of DeRF Execution User 02 Access Key"
  sensitive   = true
}

output "aws_iam_access_key_id_default_user" {
  value       = aws_iam_access_key.derf_default_user_key.id
  description = "The Id of DeRF Default User Access Key"
}

output "aws_iam_access_key_secret_default_user" {
  value       = aws_iam_access_key.derf_default_user_key.secret
  description = "The SECRET of DeRF DeRF Default User Access Key"
  sensitive   = true
}