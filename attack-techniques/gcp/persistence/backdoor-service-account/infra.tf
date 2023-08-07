locals {
  resource_prefix = "derf-backdoored"
}

resource "google_service_account" "backdoored_service_account" {
  project   = var.gcp_derf_project_id
  account_id = format("%s-sa", local.resource_prefix)
  display_name = "Service Account manipulated by the 'Backdoor Service Account Attack Technique'"
    lifecycle {
    create_before_destroy = true
  }

}

## Allow the DeRF Attacker SA01 and SA02 to setIAMPolicy on the backdoored SA
resource "google_service_account_iam_member" "derf-sa01" {
  service_account_id = google_service_account.backdoored_service_account.name
  role               = "roles/iam.serviceAccountAdmin"
  member             = var.derf-attacker-SA-01_member
}

resource "google_service_account_iam_member" "derf-sa02" {
  service_account_id = google_service_account.backdoored_service_account.name
  role               = "roles/iam.serviceAccountAdmin"
  member             = var.derf-attacker-SA-02_member
}