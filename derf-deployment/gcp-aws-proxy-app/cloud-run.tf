# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A CLOUD RUN SERVICE
# ------------------------------------------------------------------------------------------

resource "google_cloud_run_v2_service" "aws-proxy-app" {
  name     = "aws-proxy-app"
  location = local.location
  project  = var.gcp_deployment_project_id
  ingress = "INGRESS_TRAFFIC_ALL"


## Template Block
  template {

      service_account  = "${google_service_account.aws-proxy-app-service-account.email}"

    containers {
      image = "us-docker.pkg.dev/derf-artifact-registry-public/aws-proxy-app/aws-proxy-app@sha256:a6e8e4006fa6f2e0a66b24ed56efbddf13435f2f65842db8cc3f1ae503315259"

    ## Default User Credentials


      env {
        name = "AWS_ACCESS_KEY_ID"
        # value = "derf-default-accessKeyId-AWS"
        value_source {
          secret_key_ref {
            secret = var.derf_default_accessKeyId_AWS_SMID
            version = "latest"
          }
        }
      }

      env {
        name = "AWS_SECRET_ACCESS_KEY"
        # value = "derf-default-accessKeySecret-AWS"
        value_source {
          secret_key_ref {
            secret = var.derf_default_accessKeySecret_AWS_SMID
            version = "latest"
          }
        }
      }

## Derf User 01  Credentials
      env {
        name = "AWS_ACCESS_KEY_ID_USER01"
        # value = "derf-user01-accessKeyId-AWS"
        value_source {
          secret_key_ref {
            secret = var.derf_user01_accessKeyId_AWS_SMID
            version = "latest"
          }
        }
      }

      env {
        name = "AWS_SECRET_ACCESS_KEY_USER01"
        # value = "derf-user01-accessKeySecret-AWS"
        value_source {
          secret_key_ref {
            secret = var.derf_user01_accessKeySecret_AWS_SMID
            version = "latest"
          }
        }
      }

## Derf User 02  Credentials
      env {
        name = "AWS_ACCESS_KEY_ID_USER02"
        # value = "derf-user02-accessKeyId-AWS"
        value_source {
          secret_key_ref {
            secret = var.derf_user02_accessKeyId_AWS_SMID
            version = "latest"
          }
        }
      }

      env {
        name = "AWS_SECRET_ACCESS_KEY_USER02"
        # value = "derf-user02-accessKeySecret-AWS"
        value_source {
          secret_key_ref {
            secret = var.derf_user02_accessKeySecret_AWS_SMID
            version = "latest"
          }
        }
      }

    }
    
    }
    depends_on = [ google_secret_manager_secret_iam_member.binding_id_01_app,
                   google_secret_manager_secret_iam_member.binding_id_02_app,
                   google_secret_manager_secret_iam_member.binding_id_default_app,
                   google_secret_manager_secret_iam_member.binding_secret_01_app,
                   google_secret_manager_secret_iam_member.binding_secret_02_app,
                   google_secret_manager_secret_iam_member.binding_secret_default_app     
                   ]

  }


