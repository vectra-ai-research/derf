---
title: Exfiltrate Data from BigQuery Table via Unauthorized Query
---

# Exfiltrate Data from BigQuery Table via Unauthorized Query


Platform: GCP

## MITRE ATT&CK Tactics


- Exfiltration

## Description

SQL queries in BigQuery operate asynchronously through a job submission process, where the results are queried afterward. This attack technique involves executing a query on a BigQuery Table to retrieve all data from every column.

#### Attacker Actions 

The attack technique first calls the [googleapis.bigquery.v2.jobs.insert](https://cloud.google.com/workflows/docs/reference/googleapis/bigquery/v2/jobs/insert) REST API, submitting a SQL query selecting all data from the `derf-target-dev.derf_dataset.derf_table1` BigQuery Table.  

  - Log methodName : `jobservice.insert`
  - Required Permissions: `bigquery.jobs.create` and `bigquery.tables.getData`

Secondly, the attack technique calls the [googleapis.bigquery.v2.jobs.getQueryResults](https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/getQueryResults) REST API, returning the result of the previously submitted SQL query using the JobId as reference.

  - Log methodName : `jobservice.getqueryresults`
  - Required Permissions: `bigquery.jobs.create`

#### Workflow Inputs

None. The workflow will always run as Attack Execution Service Account 01 `derf-attacker-sa-01@PROJECT_ID.iam.gserviceaccount.com`

#### Clean Up: 

None


## Execution Instructions

- See User Guide for Execution Instructions via the Google Cloud Console
- Programmatically execute this workflow with the following cli command:

```
gcloud workflows run gcp-bq-data-exfilration-via-job-toc
```


## Detection Artifacts

**LogName**: `projects/-/logs/cloudaudit.googleapis.com/data_access`
**Producer**: `bigquery.googleapis.com`

Run SQL query with a Job: `googleapis.bigquery.v2.jobs.insert`
![](..../../images/jobserviceInsert.png)

Retrieve SQL query results: `googleapis.bigquery.v2.jobs.getQueryResults`

![](..../../images/jobserviceGetQueryResults.png)


## Control Objectives

Refer to the TrustOnCloud [Control Catalog Dashboard](https://controlcatalog.trustoncloud.com/dashboard/gcp/bigquery#Threat%20Catalog?Bigquery.T9) for a complete list of controls and control objectives mapped to this attack technique.

