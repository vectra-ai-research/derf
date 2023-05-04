data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_delete_cloudtrail" {
  name            = "aws-delete-cloudtrail-trail"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS Delete Cloudtrail Trail': https://stratus-red-team.cloud/attack-techniques/AWS/aws.defense-evasion.cloudtrail-delete/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Delete a CloudTrail trail. Simulates an attacker disrupting CloudTrail logging.
## Trail is recreated by the default DeRF User

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-AWS-Delete-CloudTrail-WORKFLOWEXECUTIONID"

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
    - DeleteTrail:
        call: DeleteTrail
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: deleteResponse
    - RecreateTrail:
        call: RecreateTrail
        args:
            appEndpoint: $${appEndpoint.uri}
        result: reCreateResponse
    - return:
        return: 
          - $${deleteResponse}
          - $${reCreateResponse}          


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
  
DeleteTrail:
  params: [user, appEndpoint]
  steps: 
    - DeleteTrail:
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
              BODY: '{"Name": "derf-trail"}'
              UA: '$${"Derf-AWS-Delete-CloudTrail=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              USER: $${user}
              VERB: POST
              TARGET: com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.DeleteTrail
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
          - "SUCCESS - AWS Cloudtrail Trail Deleted Attack"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Cloudtrail Trail Deleted Attack"            

RecreateTrail:
  params: [appEndpoint]
  steps: 
    - RecreateTrail:
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
              BODY: '{"Name": "derf-trail", "S3BucketName": "${local.CloudTrailBucketName}", "IsMultiRegionTrail": true, "S3KeyPrefix": "prefix"}'
              UA: "aws-cli/2.7.30 Python/3.9.11 Darwin/21.6.0 exe/x86_64 prompt/off command/cloudtrail.create-trail"
              CONTENT: "application/x-amz-json-1.1"
              VERB: POST
              TARGET: com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.CreateTrail
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
          - "SUCCESS recreating the Trail - AWS Cloudtrail Trail Deleted Attack"
    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE recreating the Trail- AWS Cloudtrail Trail Deleted Attack | This is typically a permission error"
    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE recreating the Trail - AWS Cloudtrail Trail Deleted Attack"  


  EOF

}