---
hide:
  - toc
---

# Supported Platforms

Currently, DeRF only comes with attack techniques for AWS.  See [Getting Started](../Deployment/derf-deployment.md) for deployment instructions.

# List of all Attack Techniques

This page contains the list of all DeRF Attack Techniques.

| Name   | Platform | MITRE ATT&CK Tactics |
| :----: | :------: | :------------------: |
| [Delete CloudTrail Trail](./aws/cloudtrail-delete.md) | [AWS](./AWS/index.md) | Defense Evasion |
| [Exfiltrate EBS Snapshot by Sharing It](./aws/ec2-share-ebs-snapshot.md) | [AWS](./AWS/index.md) | Exfiltration |
| [Download EC2 Instance User Data](./aws/ec2-get-user-data.md) | [AWS](./AWS/index.md) | Discovery |
| [Retrieve EC2 Password Data](./aws/ec2-get-password-data.md) | [AWS](./AWS/index.md) | Credential Access |
| [Steal EC2 Instance Credentials](./aws/ec2-steal-instance-credentials.md) | [AWS](./AWS/index.md) | Credential Access |
| [Retrieve and Decrypt SSM Parameters](./aws/ssm-retrieve-securestring-parameters.md) | [AWS](./AWS/index.md) | Credential Access |
| [AWS Retrieve a High Number of Secrets Manager secrets](./aws/secretsmanager-retrieve-secrets.md) | [AWS](./AWS/index.md) | Credential Access |
