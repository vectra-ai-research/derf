data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_ec2_get_password_data" {
  name            = "aws-ec2-get-password-data-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'AWS Retrieve EC2 Password Data' documented here: https://stratus-red-team.cloud/attack-techniques/AWS/aws.credential-access.ec2-get-password-data/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Makes the ec2:GetPasswordData API call (30) times on invalid / random EC2 instances
## Simulating an attacker attempting to retrieve RDP passwords on a high number of 
## Windows EC2 instances.
## All API calls will return a 400 HTTP response code because the EC2 instance Ids are invalid. 

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-EC2-Get-Password-Data-WORKFLOWEXECUTIONID"

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
    - GetPasswordData:
        call: GetPasswordData
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - return:
        return: $${response}   


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
GetPasswordData:
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
            - GetPasswordData:
                call: http.post
                args:
                  url: '$${appEndpoint+"/submitRequest"}'
                  auth:
                      type: OIDC
                  headers:
                    Content-Type: application/json
                  body:
                      HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                      REGION: "${data.aws_region.current.name}"
                      SERVICE: "ec2" 
                      ENDPOINT: "https://ec2.amazonaws.com/"
                      BODY: "Action=GetPasswordData&InstanceId=i-${local.random}&Version=2016-11-15"
                      UA: '$${"Derf-EC2-Get-Password-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                      CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
                      USER: $${user}
                      VERB: POST
                result: response
            - sumStep:
                assign:
                  - sum: $${sum + v}
    - return:
        return: "SUCCESS - AWS Retrieve EC2 Password Data"


  EOF

}