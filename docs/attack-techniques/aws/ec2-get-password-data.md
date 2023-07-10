---
title: AWS Retrieve EC2 Password Data
---

# AWS Retrieve EC2 Password Data


Platform: AWS

## MITRE ATT&CK Tactics


- Credential Access

## Description


Runs ec2:GetPasswordData (30) times over (30) different fictitious EC2 instances. This simulates an attacker attempting to retrieve RDP passwords on a high number of Windows EC2 instances.

See https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_GetPasswordData.html

#### Attacker Actions: 

- Attempts to receive RDP password from fictitious EC2 Instance Id.
  - Resulting event name: `GetPasswordData`
  - Assigned IAM Permission: `ec2:GetPasswordData`

#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

None

## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-delete-cloudtrail-trail `--data={"user": "user01"}` 
```


## Detection Artifacts


Identify principals making a large number of ec2:GetPasswordData calls, using CloudTrail's GetPasswordData event.

e