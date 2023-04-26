##########################################################################################
# DeRF User01 Access Key ID and Secret Storage in Secret Manager
##########################################################################################
resource "google_secret_manager_secret" "derf_user01_accessKeyId_AWS" {
  
  secret_id = "derf-user01-accessKeyId-AWS"
  replication {
    automatic = true
  }

}

resource "google_secret_manager_secret_version" "derf_user01_accessKeyId_value" {
  secret = google_secret_manager_secret.derf_user01_accessKeyId_AWS.id
  secret_data = local.derf_user01_accessKeyId_AWS

  
}

resource "google_secret_manager_secret" "derf_user01_accessKeySecret_AWS" {
  
  secret_id = "derf-user01-accessKeySecret-AWS"
  replication {
    automatic = true
  }
  

}

resource "google_secret_manager_secret_version" "derf_user01_accessKeySecret_value" {
  secret = google_secret_manager_secret.derf_user01_accessKeySecret_AWS.id
  secret_data = local.derf_user01_accessKeySecret_AWS

}

##########################################################################################
# DeRF User02 Access Key ID and Secret Storage in Secret Manager
##########################################################################################
resource "google_secret_manager_secret" "derf_user02_accessKeyId_AWS" {
  
  secret_id = "derf-user02-accessKeyId-AWS"
  replication {
    automatic = true
  }

}

resource "google_secret_manager_secret_version" "derf_user02_accessKeyId_value" {
  secret = google_secret_manager_secret.derf_user02_accessKeyId_AWS.id
  secret_data = local.derf_user02_accessKeyId_AWS


}

resource "google_secret_manager_secret" "derf_user02_accessKeySecret_AWS" {
  
  secret_id = "derf-user02-accessKeySecret-AWS"
  replication {
    automatic = true
  }

}

resource "google_secret_manager_secret_version" "derf_user02_accessKeySecret_value" {
  secret = google_secret_manager_secret.derf_user02_accessKeySecret_AWS.id
  secret_data = local.derf_user02_accessKeySecret_AWS

}