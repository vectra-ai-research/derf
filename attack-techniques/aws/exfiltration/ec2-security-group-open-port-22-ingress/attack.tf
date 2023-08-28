data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "workflow_to_invoke_ec2_security_group_open_port_22_ingress" {
  name            = "aws-ec2-security-group-open-port-22-ingress-srt"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS EC2 Steal Instance Credentials' documented here: https://stratus-red-team.cloud/attack-techniques/AWS/aws.credential-access.ec2-steal-instance-credentials/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

### Simulates an attacker loosening network restrictions to allow incoming SSH connections 
### to an EC2 instance.  This is done by creating an ingress rule in a Security Group 
### on port 22 from the Internet (0.0.0.0/0). DeRF Default Execution User reverts ingress 
### rule update, closing the open port.

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: 
##### "DeRf-AWS-EC2-SG-OPEN-INGRESS-22==SRT-WORKFLOWEXECUTIONID"

######################################################################################
## Infrastructure
######################################################################################
### This module create a new Security Group with no ingress or egress rules. 


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
    - AuthorizeSecurityGroupIngress:
        call: AuthorizeSecurityGroupIngress
        args:
            appEndpoint: $${appEndpoint.uri}
            user: $${user}
        result: response
    - return:
        return: $${response}



######################################################################################
## Submodules | Sub-Workflows
######################################################################################
AuthorizeSecurityGroupIngress:
  params: [user, appEndpoint]
  steps:
    - RevokeSecurityGroupIngress1:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            User-Agent: "Derf-Detection-Workflow"
          body:
              HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.amazonaws.com/"
              BODY: 'Action=RevokeSecurityGroupIngress&Version=2016-11-15&GroupId=${local.security_group_id}&IpPermissions.1.IpProtocol=tcp&IpPermissions.1.FromPort=223&IpPermissions.1.ToPort=22&IpPermissions.1.IpRanges.1.CidrIp=0.0.0.0%2F32'
              UA: '$${"DeRf-AWS-EC2-SG-OPEN-INGRESS-22=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              VERB: POST
        result: revokeResponse1   
    - AuthorizeSecurityGroupIngress:
        try:
            steps:
                - callStep:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                        User-Agent: "Derf-Detection-Workflow"
                      body:
                          HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "ec2" 
                          ENDPOINT: "https://ec2.amazonaws.com/"
                          BODY: "Action=AuthorizeSecurityGroupIngress&Version=2016-11-15&GroupId=${local.security_group_id}&IpPermissions.1.IpProtocol=tcp&IpPermissions.1.FromPort=22&IpPermissions.1.ToPort=22&IpPermissions.1.IpRanges.1.CidrIp=0.0.0.0%2F32"
                          UA: '$${"DeRf-AWS-EC2-SG-OPEN-INGRESS-22=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
                          USER: $${user}
                          VERB: POST
                    result: authorizeResponse
                - checkNotOK:   
                    switch:
                      - condition: $${authorizeResponse.body.responseCode == 409}
                        raise: $${authorizeResponse}
        retry:
            predicate: $${custom_predicate}
            max_retries: 8
            backoff:
                initial_delay: 1
                max_delay: 60
                multiplier: 2

    - RevokeSecurityGroupIngress2:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            User-Agent: "Derf-Detection-Workflow"
          body:
              HOST: "ec2.${data.aws_region.current.name}.amazonaws.com"
              REGION: ${data.aws_region.current.name}
              SERVICE: "ec2" 
              ENDPOINT: "https://ec2.amazonaws.com/"
              BODY: 'Action=RevokeSecurityGroupIngress&Version=2016-11-15&GroupId=${local.security_group_id}&IpPermissions.1.IpProtocol=tcp&IpPermissions.1.FromPort=22&IpPermissions.1.ToPort=22&IpPermissions.1.IpRanges.1.CidrIp=0.0.0.0%2F32'
              UA: '$${"DeRf-AWS-EC2-SG-OPEN-INGRESS-22=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-www-form-urlencoded; charset=utf-8"
              VERB: POST
        result: revokeResponse2 

    - handle_result:
        switch:
          - condition: $${authorizeResponse.body.responseCode == 200}
            next: returnValidation
          - condition: $${authorizeResponse.body.responseCode == 403}
            next: permissionError
          - condition: $${authorizeResponse.body.responseCode == 400}
            next: error

    - returnValidation:
        return: 
          - $${authorizeResponse.body.responseBody}
          - $${authorizeResponse.body.responseCode}
          - "SUCCESS - AWS Open Ingress Port 22 on a Security Group Attack Technique"

    - permissionError:
        return: 
          - $${authorizeResponse.body.responseBody}
          - $${authorizeResponse.body.responseCode}
          - "FAILURE - AWS Open Ingress Port 22 on a Security Group Attack Technique | This is typically a permission error"
    - error:
        return: 
          - $${authorizeResponse.body.responseBody}
          - $${authorizeResponse.body.responseCode}
          - "FAILURE -  AWS Open Ingress Port 22 on a Security Group Attack Technique"

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
