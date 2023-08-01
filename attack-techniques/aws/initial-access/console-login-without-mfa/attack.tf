data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}

resource "google_workflows_workflow" "workflow_to_invoke_aws_console_login_without_mfa_attack" {
  name            = "aws-console-login-without-mfa-srt"
  description     = "A  workflow intended to match the functionality of the Status Red Team attack technique 'AWS Console Login without MFA': https://stratus-red-team.cloud/attack-techniques/AWS/aws.initial-access.console-login-without-mfa/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Simulates a login to the AWS Console for an IAM user without multi-factor authentication (MFA).
## This workflow inspired by: https://naikordian.github.io/blog/posts/brute-force-aws-console/

#####################################################################################
## Input
######################################################################################
### None


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "AWS-Console-Login-Without-MFA-WORKFLOWEXECUTIONID"



######################################################################################
## Main Workflow Execution
######################################################################################
main:
  steps:
    - ConsoleLoginWithoutMFA:
        call: ConsoleLoginWithoutMFA
        result: response
    - return:
        return: $${response}


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
ConsoleLoginWithoutMFA:
  steps:  
    - ConsoleLoginWithoutMFA:
        call: http.post
        args:
          url: 'https://signin.aws.amazon.com/authenticate'
          headers:
              User-Agent: '"AWS-Console-Login-Without-MFA-"+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              Referer: 'https://signin.aws.amazon.com'
              Origin: https://signin.aws.amazon.com
              Content-Type: application/x-www-form-urlencoded
              Host: signin.aws.amazon.com
          body:
              action: "iam-user-authentication"
              account: "${data.aws_caller_identity.current.account_id}"
              username: "${aws_iam_user.console-user.name}"
              password: "${aws_iam_user_login_profile.login-profile.password}"
              client_id: "arn:aws:signin:::console/canvas"
              redirect_uri: "https://console.aws.amazon.com/console/home"
        result: response

    - handle_result:
        switch:
          - condition: $${response.code == 200}
            next: returnValidation
          - condition: $${response.body.properties.result == "MFA"}
            next: MFA
          - condition: $${response.codee == 400}
            next: error

    - returnValidation:
        return: 
          - $${response.code}
          - $${response.body}
          - "SUCCESS - AWS Console Login without MFA"

    - MFA:
        return: 
          - $${response.code}
          - $${response.body}
          - "FAILURE - AWS Console Login without MFA | User had MFA enabled"
    - error:
        return: 
          - $${response.code}
          - $${response.body}
          - "FAILURE - AWS Console Login without MFA"

  EOF

}