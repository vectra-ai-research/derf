output "google_cloudbuild_trigger_id" {
  value       = google_cloudbuild_trigger.aws_proxy_app_cloudbuild_trigger.trigger_id
  description = "The Id of Cloudbuild trigger created in this module"

}