---
title: Exfiltrate Compute Disk by sharing it
---

# Exfiltrate Compute Disk by sharing it


Platform: GCP

## MITRE ATT&CK Tactics


- Exfiltration

## Description


This attack technique shares a compute disk with a ficticious GCP Project. 
The attacker could then create a snapshot of the disk in their GCP project.

#### Attacker Actions: 

- Attempt to update the IAM policy of a compute disk granting access to a User outside of the Google Cloud Organization.
  - Resulting event name: `v1.compute.disks.setIamPolicy`
  - Assigned IAM Permission: `compute.disks.setIamPolicy`

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

Refer to Stratus Red Team documentation for detailed [detection artifacts](https://stratus-red-team.cloud/attack-techniques/GCP/gcp.exfiltration.share-compute-disk/) produced by this attack technique.

![](../../images/compute.disks.setiampolicy.png)

## Organization Policy Constraints
An organization policy is a configuration of restrictions which can be applied at several levels of your Google Cloud resource hierarchy. 

This attack technique can be prevented with the `Domain restricted sharing` constraint by making use of the `constraints/iam.allowedPolicyMemberDomains` list by confining who can be granted IAM Policy to a defined list of domains.   

See Google [Documentation](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints) for a complete list of Organization Policy Constraints available.