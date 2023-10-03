---
title: End User Execution Permissions
---

## Attack Execution - Access Control
The ability to execute an attack corresponds to the ability to invoke Cloud Workflows in your DeRF GCP Project.

##  Roles

### Execute Attacks Only
- Only the **Workflows Invoker Role** is needed to invoke the workflows and subsequently execute an attack.
    - roles/workflows.invoker

### Execute an Attack AND Triage issues
- Only the **Workflows Invoker Role** is needed to invoke the workflows and subsequently execute an attack.
    - roles/workflows.invoker
- Additional ReadOnly Roles required to give visibility into the underlying infrastructure, view logs, etc
    - roles/run.viewer
    - roles/cloudbuild.builds.viewer
    - roles/logging.viewer


## Best Practices for Role Assignment in GCP

Its best practice to assign the above clusters of Roles to groups rather than individual users or service accounts.    

    - If Google Workspace is your primary Identity Provider, create a group and assign membership under 'Directory -> Groups'. Once created in Google Workspace, your groups for Attack Execution will be available to assign Roles.   
    - If federating Google Workspace against another Identity Provider, create a group and assign membership in your Identity Provider. Sync the group and its members from your Identity Provider to Google Workspace with automatic SCIM provisioning.  Once populated in Google Workspace, your groups for Attack Execution will be available to assign Roles.    
    - If using Cloud Identity, from the cloud console, navigate to the [Groups](https://console.cloud.google.com/iam-admin/groups) page.  Create a group and assign membership.  Once created, your groups for Attack Execution will be available to assign Roles.    