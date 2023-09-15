data "google_service_account" "workflows-to-cloudrun-sa" {
  account_id   = "workflows-to-cloudrun-sa"

}
data "aws_region" "current" {}


resource "google_workflows_workflow" "workflow_to_invoke_s3_ransomware_through_clientside-encryption" {
  name            = "aws-s3-ransomware-through-clientside-encryption"
  description     = "A workflow intended to match the functionality of the  Status Red Team attack technique 'AWS S3 Ransomware through client-side encryption' documented here: https://stratus-red-team.cloud/attack-techniques/AWS/aws.impact.s3-ransomware-client-side-encryption/"
  service_account = data.google_service_account.workflows-to-cloudrun-sa.id
  project         = var.projectId
  source_contents = <<-EOF

######################################################################################
## Attack Description
######################################################################################

## Enumerate the secrets with the secretsmanager:ListSecrets API
## Retrieve each secret value, one by one with the secretsmanager:GetSecretValue API

#####################################################################################
## Input
######################################################################################
##### INPUT: {"user":"user01"}
##### INPUT: {"user":"user02"}


######################################################################################
## User Agent
######################################################################################
#### Workflow executes with the User-Agent string: "Derf-S3-Ransomware-Clientside-Encryption-WORKFLOWEXECUTIONID"

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
    - getBucketVersioning:
        call: getBucketVersioning
        args:
            user: $${user}
            appEndpoint: $${appEndpoint.uri} 
    - return:
        return: 
          - $${GetSecretValueResponse}     


######################################################################################
## Submodules | Sub-Workflows
######################################################################################
getBucketVersioning:
  params: [user, appEndpoint]
  steps: 
    - getBucketVersioning:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            User-Agent: "Derf-Detection-Workflow"
          body:
              HOST: ${var.aws_s3_bucket.derf-ransomed-bucket-clientside-encryption}.s3.${data.aws_region.current}.amazonaws.com
              REGION: ${data.aws_region.current}
              SERVICE: s3
              ENDPOINT: "https://${var.aws_s3_bucket.derf-ransomed-bucket-clientside-encryption}.s3.${data.aws_region.current}.amazonaws.com/"
              QUERYSTRING: "versioning"
              UA: '$${"Derf-S3-Ransomware-Clientside-Encryption=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              USER: $${user}
              VERB: GET
        result: response
    - return:
        return: $${response}
EOF

}