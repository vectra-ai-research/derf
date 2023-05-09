# DeRF


![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Last-Commit](https://img.shields.io/github/last-commit/vectra-ai-research/derf)          ![Maintainer](https://img.shields.io/badge/maintainer-@KatTraxler) ![Downloads](https://img.shields.io/github/downloads/vectra-ai-research/derf/total)  

Read the [Full Documentation](docs/index.md)  

DeRF (Detection Replay Framework) is "[Stratus Red Team](https://github.com/DataDog/stratus-red-team)" As A Service, allowing the emulation of offensive techniques and generation of repeatable detection samples from a UI - without the need for End Users to install software, use the CLI or possess credentials.


## Deployment
DeRF is a framework for executing attacks and generating detection samples against an AWS account.  This framework is deployed across a targeted AWS Account and a GCP Project with Terraform.
1. DeRF Framework Deployment. For more detailed instructions on deployment see: `/docs/Deployment/derf-deployment.md`

From the `./env-prod` directory, deploy the framework with terraform.
```
terraform init -backend-config=derf.conf
```
```
terraform plan -var-file=derf.tfvars
```
```
terraform apply -var-file=derf.tfvars
```


## Attack Execution
Attacks execution is performed by invoking a Google Cloud Workflow. Workflows can be invoked either on the Google Cloud Console or programmatically with the `gcloud cli`

### Executing Attacks on the Console
1. Log into the [Google Cloud Console](https://console.cloud.google.com/workflows/) and and navigate to the workflows page.
2. Click on the name of the workflow that matches the attack you want to execute.
![](/images/select-a-workflow.png)
3. Click on the `EXECUTE` button.
![](/images/execute-button.png)
4. Refer to the Code panel on the right-hand side and select which user to run the attack as by copying one of the possible inputs.
![](/images/select-a-user.png)
5. Paste selected json in the Input panel on the left-hand side.
![](/images/paste-json.png)
6. Finally, select the `EXECUTE` button at the bottom of the screen.
![](/images/execute-button-2.png)
The results of the attack will be displayed on the right-hand side of the screen.

### Executing Attacks Programmatically
1. Ensure the Google command line tool is installed locally.  Reference Google maintained [documentation](https://cloud.google.com/sdk/docs/install) for instructions on installing `gcloud cli`
2. Authenticate to Google Cloud Project which DeRF is deployed
```
gcloud auth login --project 
```
3. Invoke a particular attack techniques' workflow with the `gcloud cli`. See Google [documentation](https://cloud.google.com/sdk/gcloud/reference/workflows/run) for more complete instructions on the workflows service.

```
gcloud workflows run aws-ec2-get-user-data `--data={"user": "user01"}` 
```


## Documentation


### Building the Documentation Locally
This projects's documentation is build using [mkdocs with material](https://squidfunk.github.io/mkdocs-material/). From the root of this project you can always run mkdocs to see the rendered documentation [locally](http://localhost:8000) or use the handle Makedocs shortcut, `make docs-serve`.

1. Install Python Requirements
```
pip install mkdocs-material mkdocs-awesome-pages-plugin
```
2. Start mkdocs servcer
```
mkdocs serve --livereload
```
3. Navigate to the locally hosted documentation with your browser [127.0.0.1:8000](http://127.0.0.1:8000/)


## Acknowledgments

Maintainer: [@KatTraxler](https://twitter.com/nightmareJs)


### Similar projects 
- [Status Red Team](https://stratus-red-team.cloud) by DataDog
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team) by Red Canary
- [Leonidas](https://github.com/FSecureLABS/leonidas) by F-Secure
- [pacu](https://github.com/RhinoSecurityLabs/pacu) by Rhino Security Labs
- [Amazon GuardDuty Tester](https://github.com/awslabs/amazon-guardduty-tester)
- [CloudGoat](https://github.com/RhinoSecurityLabs/cloudgoat) by Rhino Security Labs

