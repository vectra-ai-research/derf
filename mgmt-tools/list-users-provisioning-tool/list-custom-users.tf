data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id      = "workflows-to-cloudrun-sa"
  project         = var.projectId

}

data "aws_region" "current" {}

data "google_project" "current" {
}

resource "google_workflows_workflow" "derf_management_aws_list_custom_users_tool" {
  name            = "derf-management-aws-list-custom-users-tool"
  description     = "A workflow to list the users created with the provisioning workflow, not managed by terraform"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  labels     = {
    "label" = "derf-management"
  }
  source_contents = <<-EOF

######################################################################################
## Tool Description
######################################################################################
## A workflow to list the users created with the provisioning workflow, not managed by terraform

######################################################################################
## INPUTS
######################################################################################
## None


######################################################################################
## USER-AGENT
######################################################################################
#### Excutes with User-Agent string: "DeRF-AWS-List-Custom-Users-Tool"


######################################################################################
## Main Workflow Execution
######################################################################################
main:
  steps:
    - assign:
        assign:
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}  
    - getCloudRunURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/aws-proxy-app"}'
        result: appEndpoint
    - listCustomUsers:
        call: ListCustomUsers
        args:
            appEndpoint: $${appEndpoint.uri}
        result: response
    - return:
        return: $${response}

######################################################################################
## Submodules | Sub-Workflows
######################################################################################
ListCustomUsers:
  params: [appEndpoint]
  steps: 
    - ListCustomUsers:
            steps:
              - callStep:
                  call: http.post
                  args:
                    url: '$${appEndpoint+"/submitRequest"}'
                    auth:
                        type: OIDC
                    headers:
                      User-Agent: "Derf-User-Provisioning"
                    body:
                        HOST: iam.amazonaws.com
                        REGION: ${data.aws_region.current.name}
                        SERVICE: "iam" 
                        ENDPOINT: https://iam.amazonaws.com
                        UA: '$${"DeRF-AWS-List-Custom-Users-Tool=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                        VERB: POST
                        BODY: '$${"Action=ListUsers&PathPrefix=/derfCustomUsers/&Version=2010-05-08"}'
                        CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                  result: response
    - return:
        return: $${response.body.responseBody.ListUsersResponse.ListUsersResult.Users}      


  EOF


}