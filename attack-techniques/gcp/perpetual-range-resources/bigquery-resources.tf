# ######################################################################################
# ## New BQ Dataset and child resources
# ######################################################################################

# resource "google_bigquery_dataset" "dataset" {
#   dataset_id                  = "derf_dataset"
#   friendly_name               = "derf_dataset"
#   description                 = "Dataset pre-populated as a perputual range resource during the deployment of the derf"
#   location                    = "US"
#   default_table_expiration_ms = 3600000


# }

# resource "google_bigquery_table" "table" {
#   dataset_id = google_bigquery_dataset.dataset.dataset_id
#   table_id   = "derf_table"

#   time_partitioning {
#     type = "DAY"
#   }


#   schema = <<EOF
# [
#     {
#       "description": "Full visitor ID",
#       "mode": "NULLABLE",
#       "name": "fullVisitorId",
#       "type": "STRING"
#     },
#     {
#       "description": "Visit number",
#       "mode": "NULLABLE",
#       "name": "visitNumber",
#       "type": "INTEGER"
#     },
#     {
#       "description": "Visit ID",
#       "mode": "NULLABLE",
#       "name": "visitId",
#       "type": "INTEGER"
#     },
#     {
#       "description": "Visit Start Time",
#       "mode": "NULLABLE",
#       "name": "visitStartTime",
#       "type": "INTEGER"
#     },
#     {
#       "description": "Full Date of Visit",
#       "mode": "NULLABLE",
#       "name": "fullDate",
#       "type": "DATE"
#     }
# ]
# EOF

# }


module "bigquery" {
  source                     = "terraform-google-modules/bigquery/google"
  dataset_id                 = "derf_dataset"
  dataset_name               = "derf_dataset"
  description                = "Dataset pre-populated as a perputual range resource during the deployment of the derf"
  project_id                 = var.project_id
  location                   = "US"
  delete_contents_on_destroy = var.delete_contents_on_destroy
  access = [
    {
      role          = "roles/bigquery.dataOwner"
      special_group = "projectOwners"
    }
  ]
  tables = [
    {
      table_id           = "derf_table1",
      schema             = <<EOF
[
    {
      "description": "Full visitor ID",
      "mode": "NULLABLE",
      "name": "fullVisitorId",
      "type": "STRING"
    },
    {
      "description": "Visit number",
      "mode": "NULLABLE",
      "name": "visitNumber",
      "type": "INTEGER"
    },
    {
      "description": "Visit ID",
      "mode": "NULLABLE",
      "name": "visitId",
      "type": "INTEGER"
    },
    {
      "description": "Visit Start Time",
      "mode": "NULLABLE",
      "name": "visitStartTime",
      "type": "INTEGER"
    },
    {
      "description": "Full Date of Visit",
      "mode": "NULLABLE",
      "name": "fullDate",
      "type": "DATE"
    }
]
EOF

      time_partitioning  = null,
      range_partitioning = null,
      expiration_time    = 2524604400000, # 2050/01/01
      clustering         = [],
      labels = {
        owner    = "derf"
      },
    }
  ]
  
}