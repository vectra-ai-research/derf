---
title: Troubleshooting
---


## Troubleshooting Deployment

### "*You are not authenticated against AWS, or you have not set your region.*"

You must be authenticated to AWS (and GCP) before deploying the DeRF via Terraform.
```bash
aws sso login --profile PROFILE_NAME
```

### │ Error: error configuring S3 Backend: no valid credential sources for S3 Backend found.
│
│ Please see https://www.terraform.io/docs/language/settings/backends/s3.html
│ for more information about providing credentials.
│
│ Error: SSOProviderInvalidToken: the SSO session has expired or is invalid

You must be authenticated to AWS (and GCP) before deploying the DeRF via Terraform.
```bash
aws sso login --profile PROFILE_NAME
```

### "*│ Error: Failed to read variables file*"
When running `terraform apply` the program must be to find your variables file
1. Ensure you in the `./env-prod` folder when applying the terraform.
2. Ensure the `.tfvars` file you specified is in your path


## Troubleshooting Attack Execution