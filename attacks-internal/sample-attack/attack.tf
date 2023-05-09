data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"
  projectId    = var.projectId

}


resource "google_workflows_workflow" "sample_attack" {
  name            = "aws-sample-attack"
  description     = "A template for created your own AWS Attack using the DeRF"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Describe the actions your attack will perform in the AWS Account

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "SAMPLE-ATTACK-WORKFLOWEXECUTIONID"

######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
 # Assign step always required to pull the User and current GCP Project Id 
    - assign:
        assign:
        - user: $${args.user}
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}  

# This step is always required to pull the correct URL for the Cloud Run app
    - getCloudRunURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/aws-proxy-app"}'
        result: appEndpoint 

# Call a subworkflow, passing in the user and URL of the Cloud Run App
    - SampleSubWorkflow:
        call: SampleSubWorkflow
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response

# Returned from the workflow is a list containing the response body, response code and a 
# custom message indicated Success or Failure.
    - return:
        return: $${response}      


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
SampleSubWorkflow:
  params: [user, appEndpoint]
  steps: 
    - SampleSubWorkflow:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json

# Specifiy the details of the request to make to AWS. These details can be found if you make the
# request with the AWS CLI and proxy the request through a tool such as Burp
          body:
              HOST: SERVICENAME.amazonaws.com
              REGION: REGION
              SERVICE: NAME OF AWS SERVICE 
              ENDPOINT: "https://SERVICENAME.amazonaws.com"
              BODY: IF SENDING A POST REQUEST, INCLUDE THE POST BODY HERE
              UA: '$${"SAMPLE-ATTACK=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              USER: $${user}
              VERB: POST/GET/PUT
              TARGET: Optional Header some AWS services require when submitting HTTP requests
        result: response

## Error handling logic returns custom Success message on 200 response from AWS and a custom
## Failure message on 400 or 403 HTTP response from AWS. Modify this logic if you intend for a 
## Successful attack to return something other than 200

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
          - "SUCCESS - Sample Attack"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - Sample Attack"            


  EOF

}