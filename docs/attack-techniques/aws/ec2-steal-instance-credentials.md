---
title: AWS Steal EC2 Instance Credentials
---

# AWS Steal EC2 Instance Credentials


Platform: AWS

## MITRE ATT&CK Tactics


- Credential Access

## Description

Simulates the theft of EC2 instance credentials from the Instance Metadata Service and the use of the stolen credentials outside AWS IP space.

#### Attacker Actions: 

- Attempts to SSM into EC2 instance with defined user.  Once credentials are retrieved, the workflow then calls the API 'DescribeInstances' with the EC2 instance profile credentials from the proxy-app in Google CLoud (outside AWS IP space).
  - Resulting event name: `DescribeInstances`
  - Assigned IAM Permission: `ec2:DescribeInstances`

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


GuardDuty provides two findings to identify stolen EC2 instance credentials.

- ![InstanceCredentialExfiltration.OutsideAWS](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_finding-types-iam.html#unauthorizedaccess-iam-instancecredentialexfiltrationoutsideaws) identifies EC2 instance credentials used from outside an AWS account. 
- ![InstanceCredentialExfiltration.InsideAWS](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_finding-types-iam.html#unauthorizedaccess-iam-instancecredentialexfiltrationinsideaws) identifies EC2 instance credentials used from a different AWS account than the one of the EC2 instance.

See also: ![Known detection bypasses](https://hackingthe.cloud/aws/avoiding-detection/steal-keys-undetected/).

