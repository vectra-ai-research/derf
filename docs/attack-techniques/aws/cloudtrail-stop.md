---
title: Stop CloudTrail Trail
---

# Stop CloudTrail Trail


Platform: AWS

## MITRE ATT&CK Tactics


- Defense Evasion

## Description


Stop the recording of events from a CloudTrail trail simulating an attacker disrupting logging to evade detection.

#### Attacker Actions: 

- Stop a CloudTrail trail.
  - Resulting event name: `StopTrail`
  - Assigned IAM Permission: `cloudtrail:StopTrail`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

- Restarts the CloudTrail trail.
  - Executed as the `DeRF Default User`


## Execution Instructions

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify when a CloudTrail trail is disabled through the AWS event,  `DeleteTrail`.   

Refer to Stratus Red Team documentation for additional detailed [detection artifacts](https://stratus-red-team.cloud/attack-techniques/AWS/aws.defense-evasion.cloudtrail-stop/) produced by this attack technique.

