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
| [Delete CloudTrail Trail](./aws/cloudtrail-delete.md) | [aws](./aws/index.md) | Defense Evasion |
| [Stop CloudTrail Logging](./aws/cloudtrail-stop.md) | [aws](./aws/index.md) | Defense Evasion |
| [Disable CloudTrail Logging Through Event Selectors](./aws/cloudtrail-event-selectors.md) | [aws](./aws/index.md) | Defense Evasion |
| [CloudTrail Logs Impairment Through S3 Lifecycle Rule](./aws/cloudtrail-lifecycle-rules.md) | [aws](./aws/index.md) | Defense Evasion |
| [Attempt to Leave the aws Organization](./aws/organizations-leave.md) | [aws](./aws/index.md) | Defense Evasion |
| [aws Remove VPC Flow Logs](./aws/vpc-remove-flow-log.md) | [aws](./aws/index.md) | Defense Evasion |
| [Exfiltrate EBS Snapshot by Sharing It](./aws/ec2-share-ebs-snapshot.md) | [aws](./aws/index.md) | Exfiltration |
| [Download EC2 Instance User Data](./aws/ec2-get-user-data.md) | [aws](./aws/index.md) | Discovery |
| [Retrieve EC2 Password Data](./aws/ec2-get-password-data.md) | [aws](./aws/index.md) | Credential Access |
| [Steal EC2 Instance Credentials](./aws/ec2-steal-instance-credentials.md) | [aws](./aws/index.md) | Credential Access |
| [Retrieve and Decrypt SSM Parameters](./aws/ssm-retrieve-securestring-parameters.md) | [aws](./aws/index.md) | Credential Access |
| [aws Retrieve a High Number of Secrets Manager secrets](./aws/secretsmanager-retrieve-secrets.md) | [aws](./aws/index.md) | Credential Access |
| [Execute Commands on EC2 Instance via User Data](./aws/ec2-modify-user-data.md) | [aws](./aws/index.md) | Execution |
| [Console Login without MFA](.//aws/aws-console-login-without-mfa.md) | [aws](./aws/index.md) | Initial Access |
| [Impersonate GCP Service Accounts](./gcp/impersonate-service-accounts.md) | [gcp](./gcp/index.md) | Privilege Escalation |
