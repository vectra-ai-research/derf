# DeRF Documentation Home

The DeRF, an open-source tool available on [GitHub](https://github.com/vectra-ai-research/derf), consists of Terraform modules and a Cloud Run application written in Python. Within this package, a variety of built-in attack techniques are provided, focusing on targeting AWS and GCP. For a complete accounting of all built-in attack techniques, refer to the [list](https://thederf.cloud/attack-techniques/list/) in documentation.    
<br>
The DeRF deploys and manages the target cloud infrastructure, which is manipulated to simulate attacker techniques. Terraform is used to manage all resources, deploying (and destroying) hosted attack techniques and target infrastructure in under 3 minutes.    
<br>
While a bring-your-own-Infrastructure (BYOI) model isn't currently supported, maintaining The DeRF infrastructure costs less than $10/month for Google Cloud and $5/month for AWS. The tool's convenient deployment model means you can use it as needed rather than continuously running 24/7. Check out the [deployment guide](https://thederf.cloud/Deployment/derf-deployment/) for more details.


## Key features of this tool include:  

•	<b>User-Friendly Interface</b>: Since the DeRF is hosted in Google Cloud, End Users can invoke attacks through the cloud console UI without the need to install software or use the CLI.

•	<b>Accessibility for Non-Security Professionals</b>: The DeRF caters to a broad audience of End Users, including Engineering, Sales, Support Staff, or automated processes.

•	<b>Robust OpSec</b>: Long-Lived Credentials are not passed between operators, instead access to the DeRF and its attack techniques are controlled through GCP IAM Role-Based Access Control (RBAC)

•	<b>Extensibility at its Core</b>: Attack sequences are written in YAML, enabling easy configuration of new techniques.

•	<b>Turn-Key deployment</b>: Deploying (and destroying!) the DeRF is a fully automated process, completed in under 3 minutes.



## **High Level Architecture**  

The DeRF’s unique architecture is wholly deployed via terraform.  It consists of resources spread across AWS and GCP.

### DeRF Attack Architecture for AWS  
![](./images/architecture_diagram.png)
![](./images/diagram_key.png)


### DeRF Attack Architecture for GCP 
![](./images/derf-gcp-architecture.png)
![](./images/derf-gcp-architecture-notes.png) 

## **DeRF User Personas**
See the [User Guide](./user-guide/execution-user-permissions.md) for more detailed descriptions of the permissions assigned to the DeRF Execution and Default Users.

![](./images/DeRF_Deployment_User.png){ align=left width=300 } 


^^The DeRF Deployment User^^ deploys the DeRF terraform module across AWS and GCP. Permissions required for the DeRF Deployment User are documented [here](./Deployment/deployment-permissions.md)    

<br></br>

![](./images/DeRF_Execution_User01.png){ align=left width=300 }   


^^The DeRF Execution User 01^^ is one of two built in an AWS IAM Users which AS attack techniques can run as. Permissions are assigned to the `derf-execution-users` AWS IAM Group and documented within each attack module.  
<br></br>

![](./images/DeRF_Execution_User02.png){ align=left width=300 }  


^^The DeRF Execution User 02^^ is one of two built in an AWS IAM Users which AWS attack techniques can run as. Permissions are assigned to the `derf-execution-users` AWS IAM Group and documented within each attack module.  
<br></br>

![](./images/DeRF_Default_User.png){ align=left width=300 }  


^^The DeRF Default User^^ is an AWS IAM User used by attack techniques to revert state changing actions by the AWS attack modules.  If AWS attack techniques are run with the user parameter left blank, the attack with default to run as this user.   
<br></br>

![](./images/Derf_AWS-IAM-Role.png){ align=left width=300 }   


In order to perform an attack as an arbitrary ^^AWS Role^^, AWS IAM Temporary Session Credentials generated from IAM Roles can be passed directly to the `aws-proxy-app` as Post Body Parameters additionally with the `TEMPCREDSPASSED = yes` Post Body parameter.
<br></br>

![](./images/derf-personas%20-%20sa01.png){ align=left width=300 }  

^^The DeRF Service Account 01^^ is one of two built in Service Accounts which GCP attack techniques can run as. Roles are assigned to these two DeRF Execution Service accounts in the targeted Project as part of tool deployment.   
          
<br></br> 

![](./images/derf-personas%20-%20sa02.png){ align=left width=300 }  

^^The DeRF Service Account 02^^ is one of two built in Service Accounts which GCP attack techniques can run as.Roles are assigned to these two DeRF Execution Service accounts in the targeted Project as part of tool deployment.   
          
<br></br> 

## Video Demo's
Watch this [tutorial](https://www.youtube.com/watch?v=5lsMijJoG8s) to understand, what is the DeRF, how to use it and how deploy in your environment. 