---
title: EC2 Shared EBS Snapshot
---

# EC2 Shared EBS Snapshot


Platform: AWS

## MITRE ATT&CK Tactics


- Exfiltration

## Description


This attack shares an EBS Snapshot with an external, fictitious AWS account, (012345678912)

#### Attacker Actions: 

- Updated the attributes of an EBS Snapshot to an external, fictitious AWS account.
  - Resulting event name: `ModifySnapshotAttribute`
  - Assigned IAM Permission: `ec2:ModifySnapshotAttribute`

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

