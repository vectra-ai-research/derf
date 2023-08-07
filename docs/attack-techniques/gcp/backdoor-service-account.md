---
title: Backdoor a GCP Service Account through its IAM Policy
---

# Backdoor a GCP Service Account through its IAM Policy


Platform: GCP

## MITRE ATT&CK Tactics


- Persistence

## Description


This attack technique adds an IAM Role Binding to a Service Account granting access to a User outside the Google Organization, mimicking the 'backdooring' of a service account.  This could also be considered granting 'external access'.

#### Attacker Actions 

- Attempt to setIAMPolicy on a Service Account, granting the Service Account User role to a User account outside the Organization. Because the User Account must exist, the attack technique grants access to the same valid account that Stratus Red Team does: `stratusredteam@gmail.com` 

  - Resulting event name: `google.iam.admin.v1.SetIAMPolicy`
  - Assigned IAM Permission: `iam.serviceAccounts.setIamPolicy`

#### Workflow Inputs
Specify which DeRF attacker service account this attack should run as.   
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

Refer to Stratus Red Team documentation for detailed [detection artifacts](https://stratus-red-team.cloud/attack-techniques/GCP/gcp.persistence.backdoor-service-account-policy/) produced by this attack technique.

![](../../images/iam.serviceaccount.serIAMPolicy.png)

## Organization Policy Constraints
An organization policy is a configuration of restrictions which can be applied at several levels of your Google Cloud resource hierarchy. 

This attack technique can be prevented with the `Domain restricted sharing` constraint by making use of the `constraints/iam.allowedPolicyMemberDomains` list.
See Google [Documentation](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints) for a complete list of Organization Policy Constraints available.