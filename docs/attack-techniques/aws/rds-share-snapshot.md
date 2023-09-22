---
title: Exfiltrate RDS Snapshot by Sharing
---

# Exfiltrate RDS Snapshot by Sharing


Platform: AWS

## MITRE ATT&CK Tactics


- Exfiltration

## Description


This attack shares a RDS Snapshot with a fictitious external AWS account (111122223333) to simulate an attacker exfiltrating a database.

#### Attacker Actions: 

- Calls the `ModifyDBSnapshotAttribute` API, adding the `restore` attribute and assigning that to the AWS Account, `111122223333`
  - Resulting event name: `ModifyDBSnapshotAttribute`
  - Assigned IAM Permission: `rds:ModifyDBSnapshotAttribute`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

- Removes the `restore` attribute from the fictitious external AWS account. 
  - Executed as the `DeRF Default User`


## Execution Instructions

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-rds-share-snapshot-srt `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify when a RDS snapshot is shared with an external account, through CloudTrail's <code>ModifyDBSnapshotAttribute</code> event specifically when the requestParameters.valuesToAdd key either contains an external AWS Account or the string "all".

![](../images/../../images/rds-share-snapshot.png)

Refer to Stratus Red Team documentation for additional detailed [detection artifacts](https://stratus-red-team.cloud/attack-techniques/AWS/aws.exfiltration.rds-share-snapshot/) produced by this attack technique.

