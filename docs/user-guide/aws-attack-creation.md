---
title: AWS Attack Technique Creation
---


## Building your own AWS Attack


Its possible as your use cases grow, you will want to expand on the library of built-in attack techniques and create your own custom modules.  Follow this guide for working with The DeRF to create your own workflows that execute as AWS Attack Techniques

1. Fork the `derf` repo found [here](https://github.com/vectra-ai-research/derf).

2. From the top-level directory, `attacks-internal`, review the `sample-attack` directory for an example of the structure of an AWS attack module.  Every attack module should be a folder containing at least the following files:   
      - `attack.tf`: The Google Workflow, defined in terraform, which outlines the API calls to make in the attack sequence
      - `iam-permissions.tf`: Any additional permissions need for the DeRF Execution Users to perform the attack.  Refer to the `sample-attack` directory for an example of the resources to create.
      - `variable.tf`: Refer to the `sample-attack` directory for the common variable imported into every attack.
      - `infra.tf`: If the attack technique requires any new target infrastructure, define it in this file.

3. Create your new custom DeRF attack technique as a new folder in the `attacks-internal` directory.

4. From the top-level directory, `env-prod`, review the `aws-attack-techniques-internal.tf` file.  From this file, source the newly created attack module in the style of the `sample-attack-module`.

5. Re-deploy the infrastructure  following instructions [here](../Deployment/derf-deployment.md) including the re-initalizing of terraform.


## Specifying Details of an AWS Attack Technique
Details of every API call to AWS is specified in the Google Workflows in the `http.post` request and passed to the `aws-proxy-app` for processing.  Below is a detailed accounting of the variables which can be sent to the `aws-proxy-app` to detail the API call to AWS.

### Variables
- **HOST**:   
    - description:   The value of the `Host` HTTP header to send with the API request.   Most frequently constructed as: servicename.region.amazonaws.com
    - example: *cloudtrail.us-east-1.amazonaws.com*
    - required: yes
- **REGION**: 
    - description:  Region the target infrastructure is located. 
    - example: *us-east-1*
    - required: yes
- **SERVICE**: 
    - description: Name of the service the targeted API belongs to.
    - example: *cloudtrail*
    - required: yes
- **ENDPOINT**: 
    - description: The full URL of the API call. Commonly “https:// + host header value”
    - example: *https://cloudtrail.us-east-1.amazonaws.com*
    - required: yes
- **VERB**: 
    - description: HTTP verb to send the request as.
    - example: *POST*
    - required: yes
- **BODY**: 
    - description: If POST or PUT request, the Body of the HTTP request to send.
    - example: *'{"Name": "derf-trail"}'*
    - required: no
- **UA**: 
    - description: The value of the `User-Agent` HTTP header to send with the API request.  Using the pattern below, they are recorded as unique per workflow execution, helpful in identifying attack executions within logs. 
    - example: *'$${"Derf-AWS-Delete-CloudTrail=="+sys.get_env("GOOGLE_CLOUD_WORKFLOW_EXECUTION_ID")}'*
    - required: no
- **CONTENT**: 
    - description: The value of the `Content-Type` HTTP header to send with the API request.
    - example: *"application/x-amz-json-1.1"*
    - required: no
- **USER**: 
    - description: The DeRF Execution User (either 01 or 02) to run the attack as    
    - example: *$${user}*
    - required: no
- **TARGET**: 
    - description: The value of the `X-Amz-Target` HTTP header to send with the API request. Some AWS APIs require this HTTP header to interface with the API. Proxy and record API calls from your AWS CLI traffic to understand if the API you are working with requires this header.         
    - example: *com.amazonaws.cloudtrail.v20131101.CloudTrail_20131101.DeleteTrail*
    - required: no
- **TEMPCREDSPASSED**: 
    - description: When ‘yes’, indicates to the downstream aws proxy application to except credentials sent in the HTTP header and to run the attack as.    
    - example: yes
    - required: no
- **MD5**: 
    - description: When ‘yes’, indicates to the downstream aws proxy application to calculate the MD5 hash of the post body parameters and include as a signed header. Only used in very specific AWS API calls such as `PutBucketLifecycleConfiguration`.    
    - example: yes
    - required: no
- **ACCESSKEYID, ACCESSKEYSECRET & SESSIONTOKEN**:
    - description: When included in the Google Workflow request, these temporary credentials are used by the application to run the attack as.    
    - example:
        - ACCESSKEYID: '$${ACCESSKEYID}'
        - ACCESSKEYSECRET: '$${ACCESSKEYSECRET}'
        - SESSIONTOKEN: '$${SESSIONTOKEN}'
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