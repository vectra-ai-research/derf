---
title: EC2 Get User Data
---

# EC2 Get User Data


Platform: AWS

## MITRE ATT&CK Tactics


- Discovery

## Description


 This simulates an attacker attempting to retrieve EC2 Instance User Data that frequently includes installation scripts and hard-coded secrets for deployment. This module results in an `Access Denied` error as the users are not granted the appropriate permissions

#### Attacker Actions: 

- Calls the `DescribeInstanceAttribute` API specifying the `userData` attribute (3) times on a fictitious EC2 Instance.
  - Resulting event name: `DescribeInstanceAttribute`
  - Assigned IAM Permission: None

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

None - no resources are modified.


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-ec2-get-user-data `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify when a CloudTrail trail is deleted, through CloudTrail's <code>DescribeInstanceAttribute</code> event.


