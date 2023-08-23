---
title: Execute Discovery Commands on an EC2 Instance
---

# Execute Discovery Commands on an EC2 Instance


Platform: AWS

## MITRE ATT&CK Tactics


- Discovery

## Description


This simulates an attacker performing discovery actions from a compromised EC2 instance. The commands will be run under the identity of the EC2 instance role
A smattering of discovery commands are run the targeted EC2 instance including:

- sts:GetCallerIdentity
- s3:ListBuckets
- iam:GetAccountSummary
- iam:ListRoles
- iam:ListUsers
- iam:GetAccountAuthorizationDetails
- ec2:DescribeSnapshots
- cloudtrail:DescribeTrails
- guardduty:ListDetectors
  

#### Attacker Actions: 

The following AWS API calls are made from the targeted EC2 instance:
- sts:GetCallerIdentity
- s3:ListBuckets
- iam:GetAccountSummary
- iam:ListRoles
- iam:ListUsers
- iam:GetAccountAuthorizationDetails
- ec2:DescribeSnapshots
- cloudtrail:DescribeTrails
- guardduty:ListDetectors


#### Workflow Inputs: 
Specify which user this attack should run as.   
```json
{"user":"user01"}
{"user":"user02"}
```
#### Clean Up: 

None - no resources are modified.


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run aws-ec2-get-user-data `--data={"user": "user01"}` 
```


## Detection Artifacts


Refer to Stratus Red Team documentation for detailed [detection artifacts](https://stratus-red-team.cloud/attack-techniques/AWS/aws.discovery.ec2-enumerate-from-instance/) produced by this attack technique.


