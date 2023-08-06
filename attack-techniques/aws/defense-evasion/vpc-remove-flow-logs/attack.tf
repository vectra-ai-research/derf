data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}


resource "google_workflows_workflow" "workflow_to_invoke_vpc_remove_flow_logs" {
  name            = "aws-vpc-remove-flow-logs-srt"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS Remove VPC Flow Logs': https://stratus-red-team.cloud/attack-techniques/AWS/aws.defense-evasion.vpc-remove-flow-logs/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Removes a VPC Flog Logs configuration from a VPC.
## As clean-up, this module recreates a VPC Flow Log on the targeted VPC.
## Both describing the VPCs and recreating the flow logs actions are performed by the default user.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-AWS-Remove-VPC-Flow-Logs-WORKFLOWEXECUTIONID"

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
    - RemoveFlowLog:
        call: RemoveFlowLog
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: deleteResponse
    - RecreateFlowLog:
        call: RecreateFlowLog
        args:
            appEndpoint: $${appEndpoint.uri}
        result: reCreateResponse
    - return:
        return: $${deleteResponse}        


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
RemoveFlowLog:
  params: [user, appEndpoint]
  steps: 
    - DescribeFlowLogs:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: ec2.us-east-1.amazonaws.com
              REGION: "us-east-1"
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.us-east-1.amazonaws.com"
              BODY: 'Action=DescribeFlowLogs&Version=2016-11-15'
              UA: '$${"Derf-AWS-Remove-VPC-Flow-Log=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              VERB: POST
        result: describeResponse
    - assign:
        assign:
        - flow_id: $${describeResponse.body.responseBody.DescribeFlowLogsResponse.flowLogSet.item[0].flowLogId}
    - RemoveFlowLog:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: ec2.us-east-1.amazonaws.com
              REGION: "us-east-1"
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.us-east-1.amazonaws.com"
              BODY: '$${"Action=DeleteFlowLogs&Version=2016-11-15&FlowLogId.1="+flow_id}'
              UA: '$${"Derf-AWS-Remove-VPC-Flow-Log=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              USER: $${user}
              VERB: POST
        result: response
    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: permission
          - condition: $${response.body.responseCode == 400}
            next: error

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS Remove VPC FLow Logs Attack Technique"

    - permission:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Remove VPC FLow Logs Attack Technique | This is typically a permission issue" 

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Remove VPC FLow Logs Attack Technique"            

RecreateFlowLog:
  params: [appEndpoint]
  steps: 
    - RecreateFlowLog:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: ec2.us-east-1.amazonaws.com
              REGION: "us-east-1"
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.us-east-1.amazonaws.com"
              BODY: 'Action=CreateFlowLogs&Version=2016-11-15&DeliverLogsPermissionArn=${local.log_delivery_arn}&LogGroupName=%2Fderf%2Fvpc-flow-logs&ResourceId.1=${var.vpc_id}&ResourceType=VPC&TrafficType=ACCEPT&LogDestinationType=cloud-watch-logs'
              UA: '$${"Derf-AWS-Remove-VPC-Flow-Log=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              VERB: POST
        result: response

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: error
          - condition: $${response.body.responseCode == 400}
            next: error
          - condition: $${response.body.responseBody.Response.Errors.Error.Code == "FlowLogAlreadyExists"}
            next: FlowLogAlreadyExists

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS Remove VPC FLow Logs Attack Technique - Deleted VPC Flow Logs (and subsequently Recreated the Flow Log configuration)"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS Remove VPC FLow Logs Attack Technique - unable to recreate the VPC Flow Log Configuration"   

    - FlowLogAlreadyExists:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "Unable to create a new VPC Flow log because the existing one still exists"   


  EOF

}