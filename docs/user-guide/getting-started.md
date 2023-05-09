---
title: Getting Started
---


## Step 1 - Deployment
Ensure you have deployed the DeRF resources.  The deployment includes resources in both a targeted AWS Account and the DeRF Framework components housed in a GCP Project.  See the [Deployment Guide](../Deployment/derf-deployment.md) for detailed instructions.

## Step 2 - Attack Access Control
The ability to execute an attack corresponds to the ability to invoke Cloud Workflows in your DeRF GCP Project. See the [Attack Execution Access Control](./attack-execution-access-control.md) Guide for detailed instructions on how to assign permissions to End Users for attack execution and troubleshooting.

## Step 3 - Attack Execution
Attack Techniques are codified as Google Cloud Workflows.  They can be executed as one of two predefined Users and from either the [Google Cloud Console](https://console.cloud.google.com/workflows/) or programmatically with the `gcloud cli`.        
  - See detailed [instructions](./usage.md) for executing the attacks from the [Google Cloud Console](https://console.cloud.google.com/workflows/)    
  - See detailed [instructions](./programmatic-usage.md) for executing the attacks with the `gcloud cli`
