data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

resource "google_workflows_workflow" "workflow_to_invoke_aws_ec2_get_user_data_attack" {
  name            = "aws-ec2-get-user-data-srt"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'EC2 Download User Data': https://stratus-red-team.cloud/attack-techniques/AWS/aws.discovery.ec2-download-user-data/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF


######################################################################################
## Attack Description
######################################################################################
#### Runs ec2:DescribeInstanceAttribute three times against a fictitious EC2 
#### instance ID (i-3eb15519d6788). These calls will result in access denied errors.

######################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}

######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-AWS-EC2-Get-User-Data-WORKFLOWEXECUTIONID"


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
    - DescribeInstanceAttribute1:
        call: DescribeInstanceAttribute
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - DescribeInstanceAttribute2:
        call: DescribeInstanceAttribute
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - DescribeInstanceAttribute3:
        call: DescribeInstanceAttribute
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################


DescribeInstanceAttribute:
  params: [user, appEndpoint]
  steps:  
    - DescribeInstanceAttribute:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ec2.us-east-1.amazonaws.com"
              REGION: "us-east-1"
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.amazonaws.com/"
              BODY: "Action=DescribeInstanceAttribute&Version=2016-11-15&Attribute=userData&InstanceId=i-3eb15519d6788"
              UA: '$${"Derf-AWS-EC2-Get-User-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              USER: $${user}
              VERB: POST
        result: response

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: returnValidation
          - condition: $${response.body.responseCode == 400}
            next: error

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS EC2 Get User Data Attack"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Get User Data Attack"

  EOF

}