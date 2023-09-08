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
      image = "us-docker.pkg.dev/derf-artifact-registry-public/aws-proxy-app/aws-proxy-app:latest"

    ## Default User Credentials


#       env {
#         name = "AWS_ACCESS_KEY_ID"
#         # value = "derf-default-accessKeyId-AWS"
#         value_source {
#           secret_key_ref {
#             secret = var.derf_default_accessKeyId_AWS_SMID
#             version = "latest"
#           }
#         }
#       }

#       env {
#         name = "AWS_SECRET_ACCESS_KEY"
#         # value = "derf-default-accessKeySecret-AWS"
#         value_source {
#           secret_key_ref {
#             secret = var.derf_default_accessKeySecret_AWS_SMID
#             version = "latest"
#           }
#         }
#       }

# ## Derf User 01  Credentials
#       env {
#         name = "AWS_ACCESS_KEY_ID_USER01"
#         # value = "derf-user01-accessKeyId-AWS"
#         value_source {
#           secret_key_ref {
#             secret = var.derf_user01_accessKeyId_AWS_SMID
#             version = "latest"
#           }
#         }
#       }

#       env {
#         name = "AWS_SECRET_ACCESS_KEY_USER01"
#         # value = "derf-user01-accessKeySecret-AWS"
#         value_source {
#           secret_key_ref {
#             secret = var.derf_user01_accessKeySecret_AWS_SMID
#             version = "latest"
#           }
#         }
#       }

# ## Derf User 02  Credentials
#       env {
#         name = "AWS_ACCESS_KEY_ID_USER02"
#         # value = "derf-user02-accessKeyId-AWS"
#         value_source {
#           secret_key_ref {
#             secret = var.derf_user02_accessKeyId_AWS_SMID
#             version = "latest"
#           }
#         }
#       }

#       env {
#         name = "AWS_SECRET_ACCESS_KEY_USER02"
#         # value = "derf-user02-accessKeySecret-AWS"
#         value_source {
#           secret_key_ref {
#             secret = var.derf_user02_accessKeySecret_AWS_SMID
#             version = "latest"
#           }
#         }
#       }

    }

    }
    depends_on = [ google_project_iam_member.project_iam_assignment_06]
  
  # ifecycle {
  #   ignore_changes = template[0].spec[0].containers[0].env[*]
  #     }

  }


