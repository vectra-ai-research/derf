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
# None


#### Clean Up: 
# None

## Execution Instructions

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Using CloudTrail `ConsoleLogin`` event. The field `additionalEventData.MFAUse`r is set to No when the IAM User did not use MFA to log into the console.

Note that for failed console authentication events, the field userIdentity.arn is not set (see https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-aws-console-sign-in-events.html#cloudtrail-aws-console-sign-in-events-iam-user-failure).

