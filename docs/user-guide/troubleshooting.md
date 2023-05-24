---
title: Troubleshooting
---


## Troubleshooting DeRF Deployment

1. CLI Error Message:
> "*You are not authenticated against AWS, or you have not set your region.*"  
      - You must be authenticated to AWS (and GCP) before deploying the DeRF via Terraform.  
```bash
aws sso login --profile PROFILE_NAME
```

2. CLI Error Message:
>  Error: error configuring S3 Backend: no valid credential sources for S3 Backend found.
│
│ Please see https://www.terraform.io/docs/language/settings/backends/s3.html
│ for more information about providing credentials.
│
│ Error: SSOProviderInvalidToken: the SSO session has expired or is invalid

     - You must be authenticated to AWS (and GCP) before deploying the DeRF via Terraform.   
```bash
aws sso login --profile PROFILE-NAME
```

3. CLI Error Message:
> "*│ Error: Failed to read variables file*"

    - When running `terraform apply -var-file=derf.tfvars` the program must be to find the specified variables file. Ensure you are in the `./env-prod` directory when applying the terraform. Ensure the `.tfvars` file you specified is in your path.

4. CLI Error Message:
> Error: Error creating Trigger: googleapi: Error 400: Repository mapping does not exist. Please visit https://console.cloud.google.com/i connect a repository to your project.

    - Connect Cloud Build to the `derf` github repo.  Following instructions in [Deployment](../Deployment/connect-to-github-repo.md).


## Troubleshooting Attack Execution


1. Error Message on the Google Cloud Console:
> KeyError: key not found: user

![](../images/workflow-error-1.png)

   - All workflows need to be executed with either User01 or User02. Do so by sending JSON input during workflow execution.  
    - Input Required:
        - {"user":"user01"} OR {"user":"user02"}
