output "derf_user01_accessKeyId_AWS_SMID" {
  value       = google_secret_manager_secret.derf_user01_accessKeyId_AWS.id
  description = "The Secret Manager Id for the secret: DeRF Execution User 01 Access Key ID"
  sensitive   = true
}

output "derf_user01_accessKeySecret_AWS_SMID" {
  value       = google_secret_manager_secret.derf_user01_accessKeySecret_AWS.id
  description = "The Secret Manager Id for the secret: DeRF Execution User 01 Access Key Secret"
  sensitive   = true
}

output "derf_user02_accessKeyId_AWS_SMID" {
  value       = google_secret_manager_secret.derf_user02_accessKeyId_AWS.id
  description = "The Secret Manager Id for the secret:  DeRF Execution User 02 Access Key ID"
}

output "derf_user02_accessKeySecret_AWS_SMID" {
  value       = google_secret_manager_secret.derf_user02_accessKeySecret_AWS.id
  description = "The Secret Manager Id for the secret: DeRF Execution User 02 Access Key Secret"
  sensitive   = true
}

output "derf_default_accessKeyId_AWS_SMID" {
  value       = google_secret_manager_secret.derf_default_accessKeyId_AWS.id
  description = "The Secret Manager Id for the secret:  DeRF Default User's Access Key ID"
}

output "derf_default_accessKeySecret_AWS_SMID" {
  value       = google_secret_manager_secret.derf_default_accessKeySecret_AWS.id
  description = "The Secret Manager Id for the secret: DeRF Default User's Access Key Secret"
  sensitive   = true
}