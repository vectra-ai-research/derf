# Home

Welcome to the documentation of the DeRF! THe Home page is dedicated to DeRF Installation and Requirements

## Installation
DeRF Installation consists of resource deployments from your local system to two cloud locations:   

1. A Google Cloud Project which houses the DeRF `aws-proxy-app` , a CI/CD pipeline enabling updates to the `aws-proxy-app` and a collection of cloud workflows needed for attack technique execution.   
2. An AWS Account used when targeting attacks   


### Prerequisites
1. Cloud Accounts:
    - One AWS Account
    - One GCP Project
2. Terraform variables
    - Fill out the values the `TEMPLATE.tfvars` file located in `./env-prod`
      - aws_primary_id: The AWS Account Number of your targets AWS Account
      - aws_primary_profile: The profile used to when authenticating to the targeted AWS account.  Profile can be configured in the `~/.aws/config` file. More on configuring ![profiles](https://docs.aws.amazon.com/cli/latest/reference/configure/)
      - region: The AWS region to execute attacks in
      - pathToAWSConfig: The absolute path to your `~/.aws/config` file.  Likely, /Users/computer-name/.aws/config"
      - gcp_deployment_project_id: The ID of the GCP Project to deploy the DeRF Framework components.  This value will likely consist of both letters and numbers but never numbers alone.


### System Requirements

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) version v1.4.5

##### Terraform Installation

The DeRF has only been tested with Terraform version 1.4.5.  In order to manage multiple versions of Terraform on your system, install `tfenv` command line tool, allowing you to switch between different versions of terraform.  

1. Install `tfenv`
```
brew install tfenv
```
2. Install Terraform version 1.4.5
```
tfenv install 1.4.5
```
3. Set version 1.4.5 as your default version
```
tfenv use 1.4.5
``` 


**Troubleshooting**  
If you already have Terraform on your system, you may need to unlink the cask with the following command before `tfenv` will take over Terraform installation.
```
brew unlink terraform
```


