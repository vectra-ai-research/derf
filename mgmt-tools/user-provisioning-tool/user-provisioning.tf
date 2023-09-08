data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id      = "workflows-to-cloudrun-sa"
  project         = var.projectId

}

data "aws_region" "current" {}

data "google_project" "current" {
}

resource "google_workflows_workflow" "derf_management_aws_user_provisioning_tool" {
  name            = "derf-management-aws-user-provisioning-tool"
  description     = "A workflow to create a new custom user for DeRF Execution"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  labels     = {
    "label" = "derf-management"
  }
  source_contents = <<-EOF

######################################################################################
## Tool Description
######################################################################################


######################################################################################
## INPUTS
######################################################################################
### INPUT Example: {"username":"RSmith"}

#### "Username":  The new user to create in the DeRF. This will be the value of the AWS IAM 
#### user created and the value used to execute attacks as this user



######################################################################################
## USER-AGENT
######################################################################################
#### Excutes with User-Agent string: "DeRF-AWS-User-Provisioning-Tool"

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
    - createUser:
        call: CreateUser
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - attachPolicy:
        call: AttachPolicy
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: response
    - createAccessKey:
        call: CreateAccessKey
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri}
        result: Accesskeys
    - UploadSecretToSecretManager:
        call: UploadSecretToSecretManager
        args:
            accessKeyId: $${Accesskeys[0]}
            accessKeySecret: $${Accesskeys[1]}
            user: $${user}
        result: response
    # - getProxyAppENVs:
    #     call: getProxyAppENVs
    #     result: currentENVs
    # - updateProxyApp:
    #     call: updateProxyApp
    #     args:
    #         user:      $${user}
    #     result: response
    - return:
        return: $${response}

######################################################################################
## Submodules | Sub-Workflows
######################################################################################
CreateUser:
  params: [user, appEndpoint]
  steps: 
    - CreateUser:
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
                          BODY: '$${"Action=CreateUser&Version=2010-05-08&UserName="+user+"&Tags.member.1.Key=usertype&Tags.member.1.Value=Custom"}'
                          CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                    result: response
                - checkNotOK1:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 8
            backoff:
                initial_delay: 1
                max_delay: 20
                multiplier: 2
    - return:
        return: $${response}

AttachPolicy:
  params: [user, appEndpoint]
  steps: 
    - AttachUserPolicy:
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
                          BODY: '$${"Action=AttachUserPolicy&UserName="+user+"&PolicyArn=arn:aws:iam::aws:policy/AdministratorAccess&Version=2010-05-08"}'
                          CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                    result: response
                - checkNotOK1:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
        retry:
            predicate: $${custom_predicate}
            max_retries: 8
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
                      return: "Sorry, Secret not found - so unable to delete."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to create the secret, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception:
                    raise: $${e}
    - return:
        return: $${response}


CreateAccessKey:
  params: [user, appEndpoint]
  steps: 
    - CreateAccessKey:
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
                          BODY: '$${"Action=CreateAccessKey&UserName="+user+"&Version=2010-05-08"}'
                          CONTENT: 'application/x-www-form-urlencoded; charset=utf-8'
                    result: response
                - checkNotOK:   
                    switch:
                      - condition: $${response.body.responseCode == 409}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 404}
                        raise: $${response}
                      - condition: $${response.body.responseCode == 500}
                        raise: $${response}

        retry:
            predicate: $${custom_predicate}
            max_retries: 8
            backoff:
                initial_delay: 1
                max_delay: 20
                multiplier: 2
    - return:
        return: 
          - $${response.body.responseBody.CreateAccessKeyResponse.CreateAccessKeyResult.AccessKey.AccessKeyId}
          - $${response.body.responseBody.CreateAccessKeyResponse.CreateAccessKeyResult.AccessKey.SecretAccessKey}          

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

UploadSecretToSecretManager:
  params: [user, accessKeyId, accessKeySecret]
  steps:
    - CreateSecret_AccessKeyId:
        try:
          call: googleapis.secretmanager.v1.projects.secrets.create
          args:
              parent: ${data.google_project.current.id}
              secretId: '$${"derf-"+user+"-accessKeyId-AWS"}'
              body:
                  replication:
                      automatic:
                          customerManagedEncryption:
          result: response
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
                      return: "FAILURE | Unable to create the secret, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception0:
                    raise: $${e}
    - CreateSecret_AccessKeySecret:
        try:
          call: googleapis.secretmanager.v1.projects.secrets.create
          args:
              parent: ${data.google_project.current.id}
              secretId: '$${"derf-"+user+"-accessKeySecret-AWS"}'
              body:
                  replication:
                      automatic:
                          customerManagedEncryption:
          result: response
        except:
            as: e
            steps:
                - known_errors1:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to create the secret, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception1:
                    raise: $${e}
    - AddVersion_AccessKeyId:
        try:
          call: googleapis.secretmanager.v1.projects.secrets.addVersionString
          args:
              project_id: ${var.projectId}
              secret_id: '$${"derf-"+user+"-accessKeyId-AWS"}'
              data: $${accessKeyId}
          result: response
        except:
            as: e
            steps:
                - known_errors2:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to add version to secret, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception2:
                    raise: $${e}
    - AddVersion_AccessKeySecret:
        try:
          call: googleapis.secretmanager.v1.projects.secrets.addVersionString
          args:
              project_id: ${var.projectId}
              secret_id: '$${"derf-"+user+"-accessKeySecret-AWS"}'
              data: $${accessKeySecret}
          result: response
        except:
            as: e
            steps:
                - known_errors3:
                    switch:
                    - condition: $${not("HttpError" in e.tags)}
                      return: "Connection problem."
                    - condition: $${e.code == 404}
                      return: "Sorry, URL wasn’t found."
                    - condition: $${e.code == 403}
                      return: "FAILURE | Unable to add version to secret, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception3:
                    raise: $${e}

    - return:
        return: 
            - $${response}
            - "SUCCESS | Created secrets"


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

######################

updateProxyApp:
  params: [user]
  steps:
    - patch:
        try:
          call: googleapis.run.v2.projects.locations.services.patch
          args:
              name: '$${"projects/${var.projectId}/locations/us-central1/services/aws-proxy-app"}'
              body:
                  name: '$${"projects/${var.projectId}/locations/us-central1/services/aws-proxy-app"}'
                  launchStage: GA
                  template:
                      containers: 
                        image: "us-docker.pkg.dev/derf-artifact-registry-public/aws-proxy-app/aws-proxy-app:latest"
                        env: 
############################### New Custom User #################################
                          - name: '$${"AWS_ACCESS_KEY_ID_"+user}'
                            valueSource:
                              secretKeyRef:
                                secret: '$${"derf-"+user+"-accessKeyId-AWS"}'
                                version: 'latest'
                          - name: '$${"AWS_SECRET_ACCESS_KEY_"+user}'
                            valueSource:
                              secretKeyRef:
                                secret: '$${"derf-"+user+"-accessKeySecret-AWS"}'
                                version: 'latest'
          result: patchResult
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
                      return: "FAILURE | Unable to add update the cloud run service, this is typically a permission error"
                    - condition: $${e.code == 200}
                      next: return
                - unhandled_exception:
                    raise: $${e}

    - return:
        return: 
          - '$${"SUCCESS | created new DeRF user "+user}'

  EOF


}