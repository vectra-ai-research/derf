---
title: AWS Remove VPC Flow Logs
---

# AWS Remove VPC Flow Logs


Platform: AWS

## MITRE ATT&CK Tactics


- Defense Evasion

## Description


Removes a VPC Flog Logs configuration from a VPC.

#### Attacker Actions: 

- Deletes a VPC Flow Log from a VPC.
  - Resulting event name: `DeleteFlowLogs`
  - Assigned IAM Permission: `ec2:DeleteFlowLogs`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

- Recreates the VPC Flow Log configuration.
  - Executed as the `DeRF Default User`


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Use the Cloudtrail event `DeleteFlowLogs` to identify activity.

