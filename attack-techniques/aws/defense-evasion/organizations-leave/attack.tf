data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_organizations_leave" {
  name            = "aws-organization-leave-srt"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS Attempt to Leave the AWS Organization': https://stratus-red-team.cloud/attack-techniques/AWS/aws.defense-evasion.organizations-leave/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Attempts to leave the AWS Organization 
## The API will result in a 403 HTTP response code as the users are not assigned this permission

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-AWS-Organizations-Leave-WORKFLOWEXECUTIONID"

######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - assign:
        assign:
        - user: $${args.USER}
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}  

    - getCloudRunURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/aws-proxy-app"}'
        result: appEndpoint 
    - LeaveOrganization:
        call: LeaveOrganization
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: LeaveOrganizationResponse
    - return:
        return: $${LeaveOrganizationResponse}         


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
LeaveOrganization:
  params: [user, appEndpoint]
  steps: 
    - LeaveOrganization:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: organizations.us-east-1.amazonaws.com
              REGION: "us-east-1"
              SERVICE: "organizations" 
              ENDPOINT: "https://organizations.us-east-1.amazonaws.com"
              BODY: '{}'
              UA: '$${"Derf-AWS-Organizations-Leave=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              USER: $${user}
              VERB: POST
              TARGET: AWSOrganizationsV20161128.LeaveOrganization
        result: response

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 403}
            next: returnValidation
          - condition: $${response.body.responseCode == 400}
            next: returnValidation
          - condition: $${response.body.responseCode == 500}
            next: error

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS Attempt to Leave the AWS Organization Attack"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Attempt to Leave the AWS Organization Attack"            


  EOF

}