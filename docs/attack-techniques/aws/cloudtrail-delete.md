---
title: Delete CloudTrail Trail
---

# Delete CloudTrail Trail


Platform: AWS

## MITRE ATT&CK Tactics


- Defense Evasion

## Description


Delete a CloudTrail trail simulating an attacker disrupting logging to evade detection.

#### Attacker Actions: 

- Deletes a CloudTrail trail.
  - Resulting event name: `DeleteTrail`
  - Assigned IAM Permission: `cloudtrail:DeleteTrail`

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

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify when a CloudTrail trail is deleted, through CloudTrail's <code>DeleteTrail</code> event.

GuardDuty also provides a dedicated finding type, [Stealth:IAMUser/CloudTrailLoggingDisabled](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_finding-types-iam.html#stealth-iam-cloudtrailloggingdisabled).

