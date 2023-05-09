data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id      = "workflows-to-cloudrun-sa"
  project         = var.projectId

}


resource "google_workflows_workflow" "workflow_to_trigger_cloudbuild" {
  name            = "workflow-to-trigger-cloudbuild"
  description     = "This workflow is intended to run the Cloud Build Trigger when initially deployed into an environment"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Description
######################################################################################

## This workflow is triggered by EventArc when a new CloudBuild Trigger is deployed.
## It will run and approve a newly deployed Cloud Build Trigger, not an updated one.


######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - RunTrigger:
        call: RunTrigger
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: deleteResponse
    - ApproveBuild:
        call: ApproveBuild
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
RunTrigger:
  params: [user, appEndpoint]
  steps: 
    - runTrigger:
        call: googleapis.cloudbuild.v1.projects.builds.create
        args:
        projectId: ${project_id}
        parent: ${"projects/" + project_id + "/locations/" + location_id}
        body:
            source:
            storageSource:
                bucket: ${project_id + "_cloudbuild"}
                object: "source/placeholder_src.tgz"
            steps:
            - name: "gcr.io/cloud-builders/docker"
                args:
                - "build"
                - "-t"
                - ${image_path}
                - "."
            images:
            - ${image_path}

    - return:
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