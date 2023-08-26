---
title: Console Login without MFA
---

# Console Login without MFA


Platform: AWS

## MITRE ATT&CK Tactics


- Initial Access

## Description


Simulates a login to the AWS Console for an IAM user without multi-factor authentication (MFA).

#### Attacker Actions: 

- Logs into the AWS Console with a User that does not have MFA enabled.
  - Resulting event name: `ConsoleLogin`
  - Assigned IAM Permission: NOne

#### Workflow Inputs: 
None


#### Clean Up: 
None - no infrastructure modified

## Execution Instructions

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Using AWS `ConsoleLogin` event, the field `additionalEventData.MFAUser` is set to *No* when the IAM User did not use MFA to log into the console.
  
Refer to Stratus Red Team documentation for additional detailed [detection artifacts](https://stratus-red-team.cloud/attack-techniques/AWS/aws.initial-access.console-login-without-mfa/) produced by this attack technique.

