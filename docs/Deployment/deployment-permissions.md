## Deployment Permissions

### AWS
After attempting to document individually the AWS IAM permissions required to deploy and destroy The DeRF via terraform, I gave up when the list of permissions became extensive and were "effective admin".   
I am recommending The DeRF be deployed to an targeted AWS Account with a user having the [AdministratorAccess Managed Policy](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AdministratorAccess.html).


### GCP Deployment
Below are the Google Managed Roles required to deploy the DeRF into a Google Project.  It does not take into account the permissions required to create the project in the first place.

- **roles/secretmanager.admin** applied at the Project-Level
    - Required to create Secrets used to store AWS Access Key Id and Secrets and assign Roles at the Secret-Level.
- **roles/run.admin** applied at the Project-Level
    - Required to deploy the Cloud Run `aws-proxy-app`
- **roles/artifactregistry.admin** applied at the Project-Level
    - Required when triggering Cloud Builds to store built image artifacts
- **roles/workflows.admin** applied at the Project-Level
    - Required to deploy and invoke Google Workflows
- **roles/resourcemanager.projectIamAdmin** applied at the Project-Level
    - Required to set IAM Policy at the Project level.




