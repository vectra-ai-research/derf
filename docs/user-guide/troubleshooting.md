---
title: Troubleshooting
---


## Troubleshooting Deployment

### "*You are not authenticated against AWS, or you have not set your region.*"

You must be authenticated to AWS before deploying the DeRF via Terraform.
```bash
aws sso login --profile PROFILE_NAME
```

### "*│ Error: Failed to read variables file*"
When running `terraform apply` the program must be to find your variables file
1. Ensure you in the `./env-prod` folder when applying the terraform.
2. Ensure the `.tfvars` file you specified is in your path


## Troubleshooting Attack Execution