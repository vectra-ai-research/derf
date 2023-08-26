---
title: Disable CloudTrail Logging Through Event Selectors
---

# Disable CloudTrail Logging Through Event Selectors


Platform: AWS

## MITRE ATT&CK Tactics


- Defense Evasion

## Description


Disrupt CloudTrail Logging by creating an event selector on the Trail, filtering out all management events.

#### Attacker Actions: 

- Updates the in-scope events captured by a Cloudtrail to exclude all management-plane events.
  - Resulting event name: `PutEventSelector`
  - Assigned IAM Permission: `cloudtrail:PutEventSelector`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

- Reverts the event selectors on Cloudtrail trail, resuming logging of management-plane events
  - Executed as the `DeRF Default User`


## Execution Instructions

- See [User Guide](../../user-guide/execution-user-permissions.md) for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-cloudtrail-event-selector-srt `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify when the scope of CloudTrail logging is narrowed through CloudTrail's <code>PutEventSelectors</code> event.
