output "derf-attacker-SA-01_member" {
  value       = google_service_account.derf-attacker-SA-01.member
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions."

}

output "derf-attacker-SA-02_member" {
  value       = google_service_account.derf-attacker-SA-02.member
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions."

}