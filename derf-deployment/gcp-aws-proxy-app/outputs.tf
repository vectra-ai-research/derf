output "google_cloudbuild_trigger_id" {
  value       = google_cloudbuild_trigger.aws_proxy_app_cloudbuild_trigger.trigger_id
  description = "The Id of Cloudbuild trigger created in this module"

}

output "workflows-to-cloudrun-service-account_member" {
  value       = google_service_account.workflows-to-cloudrun-service-account.member
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions"

}