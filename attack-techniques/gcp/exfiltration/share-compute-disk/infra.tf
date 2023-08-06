locals {
  disk-name = "derf-victim-disk"
}


resource "google_compute_disk" "disk" {
  project   = var.gcp_derf_project_id
  name      = local.disk-name
  size = 10 # minimum size is 10GB
  zone = "us-central1-a"
}