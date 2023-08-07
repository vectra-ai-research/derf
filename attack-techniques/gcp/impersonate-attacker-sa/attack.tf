data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_impersonate_derf_attack_sa" {
  name            = "gcp-impersonate-derf-attack-sa"
  description     = "A workflow is called by other workflows to generate an access token for the two derf attacker sa's"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################
## A workflow is called by other workflows to generate an access token for the two derf attacker sa's
## Not an attacker workflow

#####################################################################################
## Input
######################################################################################
##### INPUT: {"sa":"01"}
##### INPUT: {"sa":"02"}


######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-GCP-Impersonate-Attacker-SA-Account-WORKFLOWEXECUTIONID"


######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - assign:
        assign:
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")} 
    - ImpersonateDeRFAttackerServiceAccount:
        call: ImpersonateDeRFAttackerServiceAccount
        args:
            attackerSa: $${args}
        result: AccessToken
    - return:
        return: $${AccessToken}


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
            User-Agent: '$${"Derf-GCP-Backdoor-Service-Account=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
          body: 
            delegates: null
            scope: https://www.googleapis.com/auth/cloud-platform
            lifetime: 3600s
        result: response
    - return:
        return: $${response.body.accessToken}


  EOF

}
