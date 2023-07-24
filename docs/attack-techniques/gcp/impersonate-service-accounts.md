---
title: Impersonate GCP Service Accounts
---

# Delete CloudTrail Trail


Platform: AWS

## MITRE ATT&CK Tactics


- Privilege Escalation

## Description


Attempts to impersonate 10 different GCP service accounts in the project. Service account impersonation in GCP is the retrieval temporary credentials (OAuth bearer tokens) allowing the impersonator to 'act as' the targeted service account.

#### Attacker Actions: 

- Attempt to impersonate each of the 10 service accounts created for this detection.
Only one impersonation request will succeed, simulating a successful privilege escalation.
  - Resulting event name: `GenerateAccessToken`
  - Assigned IAM Permission: `iam.serviceAccounts.actAs`

#### Workflow Inputs: 
Specify which derf attacker service account this attack should run as.   
```json
{"sa":"01"}
{"sa":"02"}
```
#### Clean Up: 

None


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run gcp-impersonate-sa-srt `--data={"sa": "01"}` 
```


## Detection Artifacts

Using GCP Admin Activity audit logs event `GenerateAccessToken`. This event is not included in default logging and needs to be enabled. Specifically, IAM data access activity logs need to be enabled. 
The principal caller is recorded in the log whether the event was a success or resulted in an error.

![](..../../images/impersonate-sa.pngs/)

