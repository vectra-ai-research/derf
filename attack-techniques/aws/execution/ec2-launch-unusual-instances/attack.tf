data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_aws_ec2_launc_unusual_instances_attack" {
  name            = "aws-ec2-launch-unusual-instances-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'Launch Unusual Instances': https://stratus-red-team.cloud/attack-techniques/AWS/aws.execution.ec2-launch-unusual-instances/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF


######################################################################################
## Attack Description
######################################################################################
### Simulates an attacker attempting to spin up several high-powered EC2 instances (p2.xlarge) 
### which are suitable to cryptomining. 
### This attack technique ultimately fails for a couple reasons. First, the IAM role 
### assigned to the Instance Role used in the attack doesn't have the ec2:RunInstances 
### permission.  
### Secondly a service quota needs to be increased to allow for these p2.xlarge instances 
### to be created.  This module submits the service request, requesting the increase but it 
### takes several days for the request to process and may not be approved when the attack technique is executed.


######################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}

######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-AWS-EC2-Launch-Unusual-Instances-WORKFLOWEXECUTIONID"


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
    - RunInstance:        
          call: runInstances
          args:
              user: $${user}
              appEndpoint: $${appEndpoint.uri}
          result: response
    - handle_result_run_instance:
        switch:
          - condition: $${response[0] == "error"}
            next: error
          - condition: $${response[0] == "success"}
            next: RetrieveRunInstanceCommand
    - RetrieveRunInstanceCommand:
        call: retrieveResults
        args:
            COMMAND_ID: $${response[1]}
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - handle_result_retrieve_result:
        switch:
          - condition: $${response[0] == "Failed"}
            next: error
          - condition: $${response[0] == "Success"}
            next: return
          - condition: $${response[0] != "Success" or response[0] != "Failed"}
            next: error
    - error: 
        return: $${response}    
    - return:
        return: $${response}




######################################################################################
## Submodules | Sub-Workflows
######################################################################################


runInstances:
  params: [user, appEndpoint]
  steps:      
    - buildQuery:
        assign:
        - ssmCommand: '{"InstanceIds": ["${var.instance_id}"], "DocumentName": "AWS-RunShellScript", "Parameters":{"commands": ["export AWS_EXECUTION_ENV=Derf-AWS-EC2-Launch-Unusual-Instances-SRT; aws ec2 run-instances --region ${data.aws_region.current.name} --image-id $(aws ssm get-parameters --region ${data.aws_region.current.name} --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query Parameters[0].[Value] --output text) --instance-type p2.xlarge --subnet-id ${var.public_subnet_id} --security-group-ids ${var.sg_no_inbound_id} --count 10 --query Instances[*] --output text | jq -rj .InstanceId"]}}'
    - runInstances:
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
              BODY: '$${ssmCommand}'
              UA: '$${"Derf-AWS-EC2-Launch-Unusual-Instances=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              TARGET: "AmazonSSM.SendCommand"
              VERB: POST
              USER: $${user}
        result: response
        
    - handle_result:
        switch:
          - condition: $${response.body.responseBody.Command.Status == "Pending"}
            next: returnCommandId
          - condition: $${response.body.responseBody.Status != "Pending"}
            next: error
    - returnCommandId:
        return: 
            - "success"
            - $${response.body.responseBody.Command.CommandId}        
    - error:
        return: 
            - "error"
            - $${response.body}


retrieveResults:
  params: [user, appEndpoint, COMMAND_ID]
  steps: 
    - buildQuery:
        assign:
        - a: '{"CommandId": "'
        - b: '", "InstanceId": "${var.instance_id}"}'
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
              UA: '$${"Derf-AWS-EC2-Launch-Unusual-Instances=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
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
        return: 
            - $${response.body.responseBody.Status}
            - $${response.body.responseCode}
            - "SUCCESS - AWS Launch Unusual EC2 Instances | either a 200 or 403 response code could be expected" 

  EOF

}