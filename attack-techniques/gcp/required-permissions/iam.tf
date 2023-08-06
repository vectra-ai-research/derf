# ---------------------------------------------------------------------------------------------------------------------
# Project-Level IAM - Assign the execution users baseline permissions to perform attack techqnies
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_iam_member" "project_iam_assignment_SA_01" {
  project = var.gcp_derf_project_id
  role    = "roles/compute.admin"
  member  = var.derf-attacker-SA-01_member
}

resource "google_project_iam_member" "project_iam_assignment_SA_02" {
  project = var.gcp_derf_project_id
  role    = "roles/compute.admin"
  member  = var.derf-attacker-SA-02_member
}