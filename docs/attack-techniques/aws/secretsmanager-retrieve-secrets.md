---
title: AWS Retrieve a High Number of Secrets Manager secrets
---

# AWS Retrieve a High Number of Secrets Manager secrets


Platform: AWS

## MITRE ATT&CK Tactics


- Credential Access

## Description

Lists the secrets stored in Secrets Manager and retrieves (20) secret values

#### Attacker Actions: 

- First, lists the secrets stored in Secrets Manager in the current region.
- Secondly, retrieves the values of (20) secrets stored in Secrets Manager
  - Resulting event names: 
    - `ListSecrets`
    - `GetSecretValue`
  - Assigned IAM Permission: 
    - `secretsmanager:ListSecrets`
    - `secretsmanager:GetSecretValue`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

None

## Execution Instructions

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```

## Detection Artifacts

Identify principals retrieving a high number of secrets, through CloudTrail's GetSecretValue event.



