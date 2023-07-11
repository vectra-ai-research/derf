---
title: Attempt to Leave the AWS Organization
---

# Attempt to Leave the AWS Organization


Platform: AWS

## MITRE ATT&CK Tactics


- Defense Evasion

## Description


Attempts to leave the AWS Organization.  Since the execution users are not granted this permission, the attempt will fail and result in an AccessDenied error.

#### Attacker Actions: 

- Attempts to leave an AWS Organization.
  - Resulting event name: `LeaveOrganization`
  - Assigned IAM Permission: `organizations:LeaveOrganization`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

- Recreates the CloudTrail trail.
  - Executed as the `DeRF Default User`


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Any attempts from a child account to leave its AWS Organization should be considered suspicious as leaving the organization can remove security controls enforced from the Organizational Management Account

