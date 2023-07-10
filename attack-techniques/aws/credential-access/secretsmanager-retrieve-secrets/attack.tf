data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_secretmanager_retrieve_secrets" {
  name            = "aws-sm-retrieve-secrets-srt"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS Retrieve a High Number of Secrets Manager secrets' documented here: https://stratus-red-team.cloud/attack-techniques/AWS/aws.credential-access.secretsmanager-retrieve-secrets/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Enumerate the secrets with the secretsmanager:ListSecrets API
## Retrieve each secret value, one by one with the secretsmanager:GetSecretValue API

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-SM-Retrieve-Secrets-WORKFLOWEXECUTIONID"

######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - assign:
        assign:
        - user: $${args.user}
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}  

    - getCloudRunURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/aws-proxy-app"}'
        result: appEndpoint 
    - ListSecrets:
        call: ListSecrets
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: ListSecretsResponse
    - GetSecretValue:
        call: GetSecretValue
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: GetSecretValueResponse
    - return:
        return: 
          - $${GetSecretValueResponse}     


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
ListSecrets:
  params: [user, appEndpoint]
  steps: 
    - ListSecrets:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: secretsmanager.us-east-1.amazonaws.com
              REGION: "us-east-1"
              SERVICE: "secretsmanager" 
              ENDPOINT: "https://secretsmanager.us-east-1.amazonaws.com"
              BODY: "{}"
              UA: '$${"Derf-SM-Retrieve-Secret=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              USER: $${user}
              VERB: POST
              TARGET: secretsmanager.ListSecrets
        result: response

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: error
          - condition: $${response.body.responseCode == 400}
            next: error

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS Retrieve a High Number of Secrets Manager secrets"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Retrieve a High Number of Secrets Manager secrets"            
 
GetSecretValue:
  params: [user, appEndpoint]
  steps:  
    - assignStep:
        assign:
          - sum: 0
    - loopStep:
        for:
          value: v                    
          range: [1, 20]               
          steps:  
            - buildQuery:
                assign:
                - a: '{"SecretId": "derf-retrieve-secret-'
                - b: '"}'
                - c: '$${a+v+b}'          
            - GetSecretValue:
                call: http.post
                args:
                  url: '$${appEndpoint+"/submitRequest"}'
                  auth:
                      type: OIDC
                  headers:
                    Content-Type: application/json
                  body:
                      HOST: secretsmanager.us-east-1.amazonaws.com
                      REGION: "us-east-1"
                      SERVICE: "secretsmanager" 
                      ENDPOINT: "https://secretsmanager.us-east-1.amazonaws.com"
                      BODY: '$${c}'
                      UA: '$${"Derf-SM-Retrieve-Secret=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                      CONTENT: "application/x-amz-json-1.1"
                      USER: $${user}
                      VERB: POST
                      TARGET: secretsmanager.GetSecretValue
                result: response
            - sumStep:
                assign:
                  - sum: $${sum + v}
    - return:
        return: "SUCCESS - AWS Retrieve a High Number of Secrets Manager secrets"

  EOF

}