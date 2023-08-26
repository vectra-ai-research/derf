---
title: Execute Commands on EC2 Instance via User Data
---

# Execute Commands on EC2 Instance via User Data


Platform: AWS

## MITRE ATT&CK Tactics


- Execution

## Description


 Executes code on an EC2 instance as the unix root user through the modification of User Data.

References:

- https://hackingthe.cloud/aws/exploitation/local-priv-esc-mod-instance-att/
- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html

#### Attacker Actions: 

- Attacker stops the EC2 instance before modifying User Data.
  - Resulting event name: `StopInstances`
  - Assigned IAM Permission: `ec2:StopInstances`
- Attacker maliciously updates the User Data to be executed on the VM.
  - Resulting event name: `ModifyInstanceAttribute`
  - Assigned IAM Permission: `ec2:ModifyInstanceAttribute`
- Attacker restarts the EC2 instance in order for the code to execute on the machine.
  - Resulting event name: `StartInstances`
  - Assigned IAM Permission: `ec2:StartInstances`

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

Identify when the `ModifyInstanceAttribute` event occurs with requestParameters.userData non-empty and containing suspicious or unexpected data.
It's generally not expected that the user data of an EC2 instance changes often, especially with the popularity of immutable machine images, provisioned before instantiation.


