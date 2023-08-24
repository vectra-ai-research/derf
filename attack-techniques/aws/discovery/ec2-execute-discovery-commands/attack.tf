data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_ec2_execute_discovery_commands" {
  name            = "aws-ec2-execute-discovery-commands-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'AWS Execute Discovery Commands on an EC2 Instance' documented here: https://stratus-red-team.cloud/attack-techniques/AWS/aws.discovery.ec2-enumerate-from-instance/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Uses SSM to retrieve to access an EC2 instance an run a series of AWS API calls from the 
## EC2 instance, as the role associated with the EC2 instance.  This is done to simulate
## the compromise of an EC2 instance and an attacker performing a range of recon/discovery actions
## from the box.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: 
##### "Derf-AWS-EC2-Execute-Discovery-Commands-SRT-WORKFLOWEXECUTIONID"

######################################################################################
## Infrastructure
######################################################################################
### This module create a new EC2 instance specifically for the attack technique but 
### reuses a VPC, EC2 role, Instance Profile, Security Group across all attack techniques.


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
    - GetCallerIdentity:
        call: runGetCallerIdentity
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response1
    - S3LS:
        call: runS3LS
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response2
    - GetAccountSummary:
        call: runGetAccountSummary
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response3
    - ListRoles:
        call: runListRoles
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response4
    - ListUsers:
        call: runListUsers
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response5
    - GetAccountAuthorizationDetails:
        call: runGetAccountAuthorizationDetails
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response6        
    - DescribeSnaphots:
        call: runDescribeSnaphots
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response7
    - DescribeTrails:
        call: runDescribeTrails
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response8
    - ListDetectors:
        call: runListDetectors
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response9
    - createList:
        assign:
        - responseList: '$${[response1, response2, response3, response4, response5, response6, response7, response8, response9]}'         
    - check:
        switch:
          - condition: $${400 in responseList}
            next: error
          - condition: $${500 in responseList}
            next: error
          - condition: $${403 in responseList}
            next: error
          - condition: $${200 in responseList}
            next: return            
    - error:
        return:
          - $${responseList}
          - "FAILURE - AWS EC2 Execute Discovery Commands | One of the discovery commands failed to execute"   
    - return:
        return:
          - $${responseList}
          - "SUCCESS - AWS EC2 Execute Discovery Commands | All discovery commands executed"   



######################################################################################
## Submodules | Sub-Workflows
######################################################################################
runGetCallerIdentity:
  params: [appEndpoint, user]
  steps:
    - runGetCallerIdentity:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws sts get-caller-identity || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}

runS3LS:
  params: [appEndpoint, user]
  steps:
    - runS3LS:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws s3 ls || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}

runGetAccountSummary:
  params: [appEndpoint, user]
  steps:
    - runGetAccountSummary:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws iam get-account-summary || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}

runListRoles:
  params: [appEndpoint, user]
  steps:
    - runListRoles:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws iam list-roles || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}


runListUsers:
  params: [appEndpoint, user]
  steps:
    - runListUsers:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws iam list-users || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}


runGetAccountAuthorizationDetails:
  params: [appEndpoint, user]
  steps:
    - runGetAccountAuthorizationDetails:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws iam get-account-authorization-details >/dev/null || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}


runDescribeSnaphots:
  params: [appEndpoint, user]
  steps:
    - runDescribeSnaphots:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws ec2 describe-snapshots || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}

runDescribeTrails:
  params: [appEndpoint, user]
  steps:
    - runDescribeTrails:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws cloudtrail describe-trails || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}

runListDetectors:
  params: [appEndpoint, user]
  steps:
    - runListDetectors:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.${data.aws_region.current.name}.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Execute-Discovery-Commands-SRT; aws guardduty list-detectors || true"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
              UA: '$${"Derf-AWS-EC2-Execute-Discovery-Commands-SRT=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
        result: response
    - return:
        return: $${response.body.responseCode}

  EOF

}
