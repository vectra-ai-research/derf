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

- Removes the fictitious external AWS account by calling the `ModifySnapshotAttribute` API again, this time removing the permission.
  - Executed as the `DeRF Default User`

## Execution Instructions

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-ec2-share-ebs-snapshot-srt `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify when an EBS Snapshot permission is modified with the  <code>ModifySnapshotAttribute</code> event, specifically when the requestParameters.createVolumePermission contains an "add" object" and the key add.items[].userId is an external AWS Account.

![](../images/../../images/ec2-share-ebs-snapshot.png)

Refer to Stratus Red Team documentation for additional detailed [detection artifacts](https://stratus-red-team.cloud/attack-techniques/AWS/aws.exfiltration.ec2-share-ebs-snapshot/) produced by this attack technique.

