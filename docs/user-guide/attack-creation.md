---
title: Attack Technique Creation
---


## Building your own AWS Attack


Its likely you will want to expand the library of built in attack techniques and create your own.  Follow this guide for working with this framework to create your own workflows that execute as AWS Attacks

1. Fork the `derf` repo found [here](https://github.com/vectra-ai-research/derf).

2. From the top-level directory, `attacks-internal`, review the `sample-attack` directory for an example of the structure of an attack module.

3. Create a DeRF attack from the `attacks-internal` directory.

4. From the top-level directory, `env-prod`, review the `aws-attack-techniques-internal.tf` file.  From this file, source the newly created attack module in the style of the `sample-attack-module`.

5. Re-deploy the infrastructure  following instructions [here](../Deployment/derf-deployment.md) including the re-initalizing of terraform.


## Specifying Details of an Attack
Details of every API call to AWS are specified in the Google Workflows in the `http.post` request and passed to the `aws-proxy-app` for processing.  Below is a detailed accounting of the variables which can be sent to the `aws-proxy-app` to detail the API call to AWS

### Variables
- **HOST**:   
    - example: *cloudtrail.us-east-1.amazonaws.com*
    - required: yes
- **REGION**: 
    - example: *us-east-1*
    - required: yes
- **SERVICE**: 
    - example: *cloudtrail*
    - required: yes
- **ENDPOINT**: 
    - example: *https://cloudtrail.us-east-1.amazonaws.com*
    - required: yes
- **VERB**: 
    - example: *POST*
    - required: yes
- **BODY**: 
    - example: *'{"Name": "derf-trail"}'*
    - required: no
- **UA**: 
    - example: *'$${"Derf-AWS-Delete-CloudTrail=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'*
    - required: no
- **CONTENT**: 
    - example: *"application/x-amz-json-1.1"*
    - required: no
- **USER**: 
    - example: *$${user}*
    - required: no
- **TARGET**: 
    - example: *com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.DeleteTrail*
    - required: no

### Sample Google Workflow Step

```yaml
    - DeleteTrail:
        call: http.post
        args:
          url: '$${appEndpoint+"/submitRequest"}'
          auth:
              type: OIDC
          headers:
            Content-Type: application/json
          body:
              HOST: cloudtrail.us-east-1.amazonaws.com
              REGION: "us-east-1"
              SERVICE: "cloudtrail" 
              ENDPOINT: "https://cloudtrail.us-east-1.amazonaws.com"
              BODY: '{"Name": "derf-trail"}'
              UA: '$${"Derf-AWS-Delete-CloudTrail=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'
              CONTENT: "application/x-amz-json-1.1"
              USER: $${user}
              VERB: POST
              TARGET: com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.DeleteTrail
        result: response
```