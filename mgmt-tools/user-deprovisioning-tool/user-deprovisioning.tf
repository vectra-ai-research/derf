data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id      = "workflows-to-cloudrun-sa"
  project         = var.projectId

}

data "aws_region" "current" {}

resource "google_workflows_workflow" "derf_management_aws_user_deprovisioning_tool" {
  name            = "derf-management-aws-user-deprovisioning-tool"
  description     = "A workflow to delete any custom users which were created with the provisioning tool for"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  labels     = {
    "label" = "derf-management"
  }
  source_contents = <<-EOF

######################################################################################
## Tool Description
######################################################################################
## A workflow to delete any custom users which were created with the provisioning tool.
## This workflow deleted the IAM User, its access key, the access key value stored in 
## Google Secrets Manager and updated the AWS proxy app, removing the environment variables
## Pointing to those secrets.

######################################################################################
## INPUTS
######################################################################################
### INPUT Example: {"username":"RSmith"}

#### "Username":  The user to delete in the DeRF. This will be the value of the AWS IAM 
#### user created and the value used to execute attacks as this user



######################################################################################
## USER-AGENT
######################################################################################
#### Excutes with User-Agent string: "DeRF-AWS-User-DeProvisioning-Tool"

######################################################################################
## TroubleshootingTips
######################################################################################



######################################################################################
## Main Workflow Execution
######################################################################################
main:
  params: [args]
  steps:
    - assign:
        assign:
        - user: $${args.username}
        - projectID: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}  
    - getCloudRunURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/aws-proxy-app"}'
        result: appEndpoint
    - getGcloudAppURL:
        call: googleapis.run.v2.projects.locations.services.get
        args:
          name: '$${"projects/"+projectID+"/locations/us-central1/services/gcloud-app"}'
        result: gcloudAppEndpoint
    - detachUserPolicy:
        call: DetachUserPolicy
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response 
    - listAccessKeys:
        call: ListAccessKeys
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - deleteAccessKey:
        call: DeleteAccessKey
        args:
            user: $${user}
            accessKeyId: $${response.body.responseBody.ListAccessKeysResponse.ListAccessKeysResult.AccessKeyMetadata.member.AccessKeyId}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - deleteUser:
        call: DeleteUser
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - deleteSecretsFromSecretsManager:
        call: DeleteSecretsFromSecretsManager
        args:
            user: $${user}
        result: response
    - updateProxyApp:
        call: updateProxyApp
        args:
            user: $${user}
            gcloudAppEndpoint: $${gcloudAppEndpoint.uri}
        result: response
    - return:
        return: $${response}

######################################################################################
## Submodules | Sub-Workflows
######################################################################################
DetachUserPolicy:
  params: [user, appEndpoint]
  steps: 
    - DetachhUserPolicy:
        try:
            steps:
                - callStep:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                        User-Agent: "Derf-User-Provisioning"
                      body:
                          HOST: iam.amazonaws.com
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "iam" 
                          ENDPOINT: https://iam.amazonaws.com
                          UA: '$${"DeRF-AWS-User-Provisioning-Tool=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          VERB: POST
                          BODY: '$${"Action=DetachUserPolicy&UserName="+user+"&PolicyArn=arn:aws:iam::aws:policy/AdministratorAccess&Version=2010-05-08"}'
                          CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                    result: response
                - checkNotOK1:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 3
            backoff:
                initial_delay: 1
                max_delay: 20
                multiplier: 2
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, unable to detach the policy."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to detach the policy, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception:
                    raise: $${e}
    - return:
        return: $${response}

ListAccessKeys:
  params: [user, appEndpoint]
  steps: 
    - ListAccessKeys:
        try:
            steps:
                - callStep:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                        User-Agent: "Derf-User-Provisioning"
                      body:
                          HOST: iam.amazonaws.com
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "iam" 
                          ENDPOINT: https://iam.amazonaws.com
                          UA: '$${"DeRF-AWS-User-Provisioning-Tool=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          VERB: POST
                          BODY: '$${"Action=ListAccessKeys&UserName="+user+"&Version=2010-05-08"}'
                          CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                    result: response
                - checkNotOK1:   
                    switch:
                      - condition: $${response.body.responseCode == 404}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 500}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 3
            backoff:
                initial_delay: 1
                max_delay: 20
                multiplier: 2
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "FAILURE | Unable to find the DeleteUser API."
                    - condition: $${e.code == 409}
                      return: "FAILURE | Unable to delete the user - user doesn't exist"
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to delete the user, this is typically a permission error"
                    - condition: '$${e.message == "KeyError: key not found: tags"}'
                      return: "FAILURE | User doesn't exists"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception:
                    raise: $${e}
    - return:
        return: $${response}

DeleteAccessKey:
  params: [appEndpoint, accessKeyId, user]
  steps: 
    - DeleteAccessKey:
        try:
            steps:
                - callStep:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                        User-Agent: "Derf-User-Provisioning"
                      body:
                          HOST: iam.amazonaws.com
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "iam" 
                          ENDPOINT: https://iam.amazonaws.com
                          UA: '$${"DeRF-AWS-User-Provisioning-Tool=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          VERB: POST
                          BODY: '$${"Action=DeleteAccessKey&UserName="+user+"&AccessKeyId="+accessKeyId+"&Version=2010-05-08"}'
                          CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                    result: response
                - checkNotOK1:   
                    switch:
                      - condition: $${response.body.responseCode == 404}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 500}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 3
            backoff:
                initial_delay: 1
                max_delay: 20
                multiplier: 2
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "FAILURE | Unable to find the DeleteAccessKey API."
                    - condition: $${e.code == 409}
                      return: "FAILURE | Unable to delete the Access Key - user doesn't exist"
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to delete the user, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception:
                    raise: $${e}
    - return:
        return: $${response}



DeleteUser:
  params: [user, appEndpoint]
  steps: 
    - DeleteUser:
        try:
            steps:
                - callStep:
                    call: http.post
                    args:
                      url: '$${appEndpoint+"/submitRequest"}'
                      auth:
                          type: OIDC
                      headers:
                        User-Agent: "Derf-User-Provisioning"
                      body:
                          HOST: iam.amazonaws.com
                          REGION: ${data.aws_region.current.name}
                          SERVICE: "iam" 
                          ENDPOINT: https://iam.amazonaws.com
                          UA: '$${"DeRF-AWS-User-Provisioning-Tool=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
                          VERB: POST
                          BODY: '$${"Action=DeleteUser&UserName="+user+"&Version=2010-05-08"}'
                          CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                    result: response
                - checkNotOK1:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 404}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 500}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 3
            backoff:
                initial_delay: 1
                max_delay: 20
                multiplier: 2

        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 409}
                      return: "FAILURE | Unable to Delete User - Can't find user"
                    - condition: $${e.code == 404}
                      return: "FAILURE | DeleteUser endpoint not found"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception:
                    raise: $${e}

    - return:
        return: $${response}


custom_predicate:
  params: [response]
  steps:
    - what_to_repeat:
        switch:
          - condition: $${response.body.responseCode == 404}
            return: true
          - condition: $${response.body.responseCode == 500}
            return: true
    - otherwise:
        return: false


DeleteSecretsFromSecretsManager:
  params: [user]
  steps:
    - DeleteSecret_AccessKeyId:
        try:
          call: googleapis.secretmanager.v1.projects.secrets.delete
          args:
              name: '$${"projects/${var.projectId}/secrets/derf-"+user+"-accessKeyId-AWS"}'
        except:
            as: e
            steps:
                - known_errors0:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, Secret not found - so unable to delete."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to create the secret, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}
    - DeleteSecret_AccessKeySecret:
        try:
          call: googleapis.secretmanager.v1.projects.secrets.delete
          args:
              name: '$${"projects/${var.projectId}/secrets/derf-"+user+"-accessKeySecret-AWS"}'
          result: response
        except:
            as: e
            steps:
                - known_errors1:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, Secret not found - so unable to delete."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to create the secret, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception1:
                    raise: $${e}
  
    - return:
        return: 
            - $${response}
            - '$${"SUCCESS | Deleted user: "+user}'

##################

getProxyAppENVs:
  steps:
    - getProxyAppENVs:
        try:
          call: googleapis.run.v2.projects.locations.services.revisions.get
          args:
              name: '$${"projects/${var.projectId}/locations/us-central1/services/aws-proxy-app"}'
          result: result
        except:
            as: e
            steps:
                - known_errors0:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to add update the cloud run service, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}
    - return:
        return: $${result.template.containers[0].env}




   


updateProxyApp:
  params: [user, gcloudAppEndpoint]
  steps:
    - callStep:
        try:
          call: http.post
          args:
            url: '$${gcloudAppEndpoint+"/updateSecrets"}'
            auth:
                type: OIDC
            headers:
              User-Agent: "Derf-User-Provisioning"
            body:
                REMOVEUSER: $${user}
          result: response
        except:
            as: e
            steps:
                - known_errors:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 500}
                      next: return
                    - condition: $${response.code == 500}
                      next: return
                - unhandled_exception:
                    raise: $${e}

    - return:
        return: '$${"User Deleted: " +user}'
        

  EOF


}