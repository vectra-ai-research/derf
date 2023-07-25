---
hide:
  - toc
---

# Supported Platforms

Currently, The DeRF only comes with attack techniques for AWS and GCP.   
See [Getting Started](../Deployment/derf-deployment.md) for deployment instructions.

# List of all Attack Techniques

This page contains the list of all DeRF Attack Techniques.

| Name   | Platform | MITRE ATT&CK Tactics |
| :----: | :------: | :------------------: |
| [Delete CloudTrail Trail](./AWS/cloudtrail-delete.md) | [AWS](./AWS/index.md) | Defense Evasion |
| [Stop CloudTrail Logging](./AWS/cloudtrail-stop.md) | [AWS](./AWS/index.md) | Defense Evasion |
| [Disable CloudTrail Logging Through Event Selectors](./AWS/cloudtrail-event-selectors.md) | [AWS](./AWS/index.md) | Defense Evasion |
| [CloudTrail Logs Impairment Through S3 Lifecycle Rule](./AWS/cloudtrail-lifecycle-rules.md) | [AWS](./AWS/index.md) | Defense Evasion |
| [Attempt to Leave the AWS Organization](./AWS/organizations-leave.md) | [AWS](./AWS/index.md) | Defense Evasion |
| [AWS Remove VPC Flow Logs](./AWS/vpc-remove-flow-log.md) | [AWS](./AWS/index.md) | Defense Evasion |
| [Exfiltrate EBS Snapshot by Sharing It](./AWS/ec2-share-ebs-snapshot.md) | [AWS](./AWS/index.md) | Exfiltration |
| [Download EC2 Instance User Data](./AWS/ec2-get-user-data.md) | [AWS](./AWS/index.md) | Discovery |
| [Retrieve EC2 Password Data](./AWS/ec2-get-password-data.md) | [AWS](./AWS/index.md) | Credential Access |
| [Steal EC2 Instance Credentials](./AWS/ec2-steal-instance-credentials.md) | [AWS](./AWS/index.md) | Credential Access |
| [Retrieve and Decrypt SSM Parameters](./AWS/ssm-retrieve-securestring-parameters.md) | [AWS](./AWS/index.md) | Credential Access |
| [AWS Retrieve a High Number of Secrets Manager secrets](./AWS/secretsmanager-retrieve-secrets.md) | [AWS](./AWS/index.md) | Credential Access |
| [Execute Commands on EC2 Instance via User Data](./AWS/ec2-modify-user-data.md) | [AWS](./AWS/index.md) | Execution |
| [Impersonate GCP Service Accounts](./GCP/impersonate-service-accounts.md) | [GCP](./GCP/index.md) | Privilege Escalation |
