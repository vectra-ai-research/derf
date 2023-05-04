---
title: Delete CloudTrail Trail
---

# Delete CloudTrail Trail


Platform: AWS

## MITRE ATT&CK Tactics


- Defense Evasion

## Description


Delete a CloudTrail trail simulating an attacker disrupting logging to evade detection.

<span style="font-variant: medium-caps;">Attacker Actions</span>: 

- Deletes a CloudTrail trail.
  - Event Name: `DeleteTrail`

<span style="font-variant: medium-caps;">Workflow Inputs</span>: 
Specify which user this attack should run as.
```json
{"user":"user01"}
{"user":"user02"}
```
<span style="font-variant: medium-caps;">Clean Up</span>: 

- Recreates the CloudTrail trail.
  - Executed as the `DeRF Default User`


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection


Identify when a CloudTrail trail is deleted, through CloudTrail's <code>DeleteTrail</code> event.

GuardDuty also provides a dedicated finding type, [Stealth:IAMUser/CloudTrailLoggingDisabled](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_finding-types-iam.html#stealth-iam-cloudtrailloggingdisabled).

