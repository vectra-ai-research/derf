data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

resource "google_workflows_workflow" "workflow_to_invoke_cloudtrail_stop" {
  name            = "aws-cloudtrail-stop-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'AWS Stop CloudTrail Trail': https://stratus-red-team.cloud/attack-techniques/AWS/aws.defense-evasion.cloudtrail-stop/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Stops a CloudTrail Trail from logging. Simulates an attacker disrupting CloudTrail logging.
## Trail is restrarted by the default DeRF User

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-AWS-Stop-CloudTrail-WORKFLOWEXECUTIONID"

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
    - StopLogging:
        call: StopLogging
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: StopLoggingResponse
    - ReStartLogging:
        call: ReStartLogging
        args:
            appEndpoint: $${appEndpoint.uri}
        result: ReStartLoggingResponse
    - return:
        return: 
          - $${StopLoggingResponse}
          - $${ReStartLoggingResponse}          


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
StopLogging:
  params: [user, appEndpoint]
  steps: 
    - StopLogging:
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
              BODY: '{"Name": "${var.TrailName}"}'
              UA: '$${"Derf-AWS-Stop-CloudTrail=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              USER: $${user}
              VERB: POST
              TARGET: com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.StopLogging
        result: response

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
          - "SUCCESS - AWS Stop CloudTrail Trail Attack"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE restarting the Trail - AWS Stop CloudTrail Trail Attack | This is typically a permission error"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Stop CloudTrail Trail Attack"            

ReStartLogging:
  params: [appEndpoint]
  steps: 
    - ReStartLogging:
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
              BODY: '{"Name": "${var.TrailName}"}'
              UA: '$${"Derf-AWS-Stop-CloudTrail=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              VERB: POST
              TARGET: com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.StartLogging
        result: response

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
          - "SUCCESS restarting the Trail - AWS Stop CloudTrail Trail Attack"
    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE restarting the Trail - AWS Stop CloudTrail Trail Attack | This is typically a permission error"
    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE restarting the Trail - AWS Stop CloudTrail Trail Attack"  


  EOF

}