
output "workflows-to-cloudrun-service-account_member" {
  value       = google_service_account.workflows-to-cloudrun-service-account.member
  description = "The Identity of the service account in the form serviceAccount:{email}.  This value is often used to refer to the service account in order to grant IAM permissions"

}

output "aws-proxy-app-service-account_id" {
  value       = google_service_account.aws-proxy-app-service-account.id
  description = "The ID of the service account as the Identity for the AWS Proxy App"

}