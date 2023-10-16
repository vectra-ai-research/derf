### Deployment Steps

1. Complete Prerequisites [see below](#prerequisites).
2. Complete System Requirements [see below](#system-requirements).
3. Clone the Github repo to your local system.
``` bash
git clone https://github.com/vectra-ai-research/derf.git
```
1. Deploy the DeRF via Terraform from the `./env-prod` directory.   
``` tf
export AWS_PROFILE=PROFILE   
```   

``` tf
terraform init -backend-config=derf.conf   
```   

``` tf
terraform plan -var-file=derf.tfvars   
```   

``` tf
terraform apply -var-file=derf.tfvars   
```   


   
## Prerequisites
1. Cloud Accounts:
    - ==One AWS Account==: 
        - This is your targeted AWS Account where attacks will run.
    - ==TWO GCP Projects==: 
        - Deployment Project: A Google Cloud Project which will house the DeRF `aws-proxy-app`  
        - Target Project: A Google Cloud Project which will be the target of attack techniques. 
2. Terraform Variables
    - Fill out the values the `TEMPLATE.tfvars` file located in `./env-prod` directory.
    - Rename this file to be `derf.tfvars`
    - Terraform **Variables**:
        - ^^aws_account_id^^: The Account ID to deploy the target AWS resources in.
        - ^^gcp_deployment_project_id^^: The ID of the GCP Project to deploy the DeRF Framework components.  This value may consist of both letters and numbers but never numbers alone.
        - ^^gcp_derf_project_id^^: The ID of the GCP Project to deploy target resources. This value may consist of both letters and numbers but never numbers alone.
3. Backend Configuration
    - Fill out the values the `TEMPLATE.conf` file located in `./env-prod` directory.
    - Rename this file to be `derf.conf`
    - Why run Terraform with a remote backend?
      - Running a remote backend to an encrypted S3 bucket is recommended as AWS Access Keys are generated during this `Terraform Apply` and will otherwise be retained locally in the state file.
    - Backend **configuration values**:
        - ^^bucket^^: Name of the S3 bucket to store remote Terraform State. This should minimally be SSE-S3 encrypted. 
            - *Example: "my-bucket-002984"*
        - ^^region^^: The region your backend bucket is located in.





## System Requirements


<div class="grid" markdown>

=== "Terraform Installation" 

    The DeRF has been tested verified with Terraform version `1.6.0`.  In order to manage multiple versions of Terraform on your system, install `tfenv` command line tool, allowing you to switch between different versions of terraform. 

1. Install `tfenv`
``` bash
brew install tfenv
``` 
1. Install Terraform version 1.6.0
``` bash
tfenv install 1.6.0
```
1. Set version 1.6.0 as your default version
``` bash
tfenv use 1.6.0
```     

</div>


<div class="grid" markdown>

=== "gcloud Installation"

During deployment, the `gcloud` cli is invoked to trigger Cloud Build and deploy the `aws-proxy-app` to Cloud Run. As a result, `gcloud`  will need to be installed on your local system in order to deploy The DeRF.  

Download and install the `gcloud` cli per instructions located [here](https://cloud.google.com/sdk/docs/install).


</div>




## Troubleshooting 
If you already have Terraform on your system, you may need to unlink the cask with the following command before `tfenv` will take over Terraform installation.
``` bash
brew unlink terraform
```