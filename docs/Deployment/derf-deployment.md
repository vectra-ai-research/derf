### Deployment Steps

1. Complete Prerequisites (see below).
2. Complete System Requirements (see below).
3. Clone the Github repo to your local system.
``` bash
git clone https://github.com/vectra-ai-research/derf-vectra-private.git
```
4. Deploy the DeRF via Terraform from the `./env-prod` directory.
``` tf
terraform init -backend-config=derf.conf
```
``` tf
terraform plan -var-file=derf.tfvars
```
``` tf
terraform apply -var-file=derf.tfvars
```
![](https://img.shields.io/badge/-ATTENTION-red) If this is your first installation - follow the additional   
      - Navigate the the [CloudBuild console](https://console.cloud.google.com/cloud-build/triggers) in your GCP Project
      - Click on 'Triggers' and find the 'Github-Trigger-derf-aws-proxy-app-repo-main' Trigger.  
      - Select 'Run' to invoke this Trigger.  
      - Then click on the 'History' tab to approve the build. 
This will deploy the CORRECT image into Cloud Run. If you don't manually run this on initial deployment, the `aws-proxy-app` will not work.

   
## Prerequisites
1. Cloud Accounts:
    - ==One AWS Account==: 
        - This is your targeted AWS Account where attacks will run.
    - ==One GCP Project==: 
        - A Google Cloud Project which will house the DeRF `aws-proxy-app` , a CI/CD pipeline enabling updates to the `aws-proxy-app` and a collection of cloud workflows needed for attack technique execution. 
2. Terraform Variables
    - Fill out the values the `TEMPLATE.tfvars` file located in `./env-prod` directory.
    - Rename this file to be `derf.tfvars`
    - Terraform **Variables**:
        - ^^aws_primary_id^^: The AWS Account Number of your targets AWS Account
        - ^^aws_primary_profile^^: The profile used to when authenticating to the targeted AWS account. Profile can be configured in the `~/.aws/config` file. More on configuring [profiles](https://docs.aws.amazon.com/cli/latest/reference/configure/)
        - ^^region^^: The AWS region to execute attacks in.
        - ^^pathToAWSConfig^^: The absolute path to your `~/.aws/config` file. 
            - *Example: "/Users/computer-name/.aws/config"*
        - ^^gcp_deployment_project_id^^: The ID of the GCP Project to deploy the DeRF Framework components.  This value will likely consist of both letters and numbers but never numbers alone.
3. Backend Configuration
    - Fill out the values the `TEMPLATE.conf` file located in `./env-prod` directory.
    - Rename this file to be `derf.conf`
    - Why run Terraform with a remote backend?
      - Running a remote backend to an encrypted S3 bucket is recommended as AWS Access Keys are generated during this `Terraform Apply` and will otherwise be retained locally in the state file.
    - Backend **configuration values**:
        - ^^region^^: The AWS region to execute attacks in.
        - ^^bucket^^: Name of the S3 bucket to store remote Terraform State. This should minimally be SSE-S3 encrypted.
            - *Example: "my-bucket-002984"*
        - ^^profile^^: The profile used to when authenticating to the AWS Account where the S3 bucket resides. This profile needs write access to the S3 bucket. It does not need to be the same as the Targeted AWS Account. Profile can be configured in the `~/.aws/config` file. More on configuring [profiles](https://docs.aws.amazon.com/cli/latest/reference/configure/)  


## System Requirements

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) version v1.4.5

#### Terraform Installation

The DeRF has only been tested with Terraform version 1.4.5.  In order to manage multiple versions of Terraform on your system, install `tfenv` command line tool, allowing you to switch between different versions of terraform.  

1. Install `tfenv`
``` bash
brew install tfenv
``` 
2. Install Terraform version 1.4.5
``` bash
tfenv install 1.4.5
```
3. Set version 1.4.5 as your default version
``` bash
tfenv use 1.4.5
``` 


**Troubleshooting**  
If you already have Terraform on your system, you may need to unlink the cask with the following command before `tfenv` will take over Terraform installation.
``` bash
brew unlink terraform
```