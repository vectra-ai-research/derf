---
title: AWS Retrieve and Decrypt SSM Parameters
---

# AWS Retrieve and Decrypt SSM Parameters


Platform: AWS

## MITRE ATT&CK Tactics


- Credential Access

## Description

Describes the SSM Parameters in an Account and retrieves and decrypts (30) SSM Parameters available in an AWS region.

#### Attacker Actions: 

- First, lists the SSM Parameters in the current region.
- Secondly, retrieves the values of (30) SSM Parameters.
  - Resulting event names: 
    - `DescribeParameters`
    - `GetParameter`
  - Assigned IAM Permission: 
    - `ssm:DescribeParameters`
    - `ssm:GetParameter`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

None

## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts

Identify principals retrieving a high number of SSM Parameters, through CloudTrail's GetParameter event. It is especially suspicious when the `requestParameters` contains the following key value/pair `"withDecryption": true` as this might indicate the parameters retrieved were deemed sensitive enough to be KMS encrypted.


