---
title: CloudTrail Logs Impairment Through S3 Lifecycle Rule
---

# CloudTrail Logs Impairment Through S3 Lifecycle Rule


Platform: AWS

## MITRE ATT&CK Tactics


- Defense Evasion

## Description


Set a 1-day retention policy on the S3 bucket used by a CloudTrail Trail, using a S3 Lifecycle Rule.

#### Attacker Actions: 

- Updates the Lifecycle rule on the S3 bucket backing the CloudTrail trail to 1 day.
  - Resulting event name: `PutBucketLifecycle`
  - Assigned IAM Permission: `s3:PutBucketLifecycle`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

- Resets Lifecycle configuration to 30 days.
  - Executed as the `DeRF Default User`


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify when lifecycle rule with a short expiration is applied to an S3 bucket used for CloudTrail logging.

The CloudTrail event <code>PutBucketLifecycle</code> and its attribute requestParameters.LifecycleConfiguration.Rule.Expiration.Days can be used.

