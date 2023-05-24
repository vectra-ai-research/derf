# DeRF Documentation Home
 
Welcome to the Home Page of the DeRF Documentation.


## **High Level Architecture**  

DeRF Deployment and Execution targeting AWS
  
![](./images/DeRF%20Architecture.png)


## **DeRF User Personas**
See the [User Guide](./user-guide/execution-user-permissions.md) for more detailed descriptions of the permissions assigned to the DeRF Execution and Default Users.

![](./images/DeRF_Deployment_User.png){ align=left width=300 } 


^^The DeRF Deployment User^^ deploys the DeRF terraform module across AWS and GCP. Permissions required for the DeRF Deployment User are documented [here](./Deployment/deployment-permissions.md)    

<br></br>

![](./images/DeRF_Execution_User01.png){ align=left width=300 }   


^^The DeRF Execution User 01^^ is one of two built in an AWS IAM Users which attack techniques can run as. Permissions are assigned to the `derf-execution-users` AWS IAM Group and documented within each attack module.  
<br></br>

![](./images/DeRF_Execution_User02.png){ align=left width=300 }  


^^The DeRF Execution User 02^^ is one of two built in an AWS IAM Users which attack techniques can run as. Permissions are assigned to the `derf-execution-users` AWS IAM Group and documented within each attack module.  
<br></br>

![](./images/DeRF_Default_User.png){ align=left width=300 }  


^^The DeRF Default User^^ is an AWS IAM User used by attack techniques to revert state changing actions by the attack modules.  If attack techniques are run with the user parameter left blank, the attack with default to run as this user.   
<br></br>

![](./images/Derf_AWS-IAM-Role.png){ align=left width=300 }   


In order to perform an attack as an arbitrary ^^AWS Role^^, AWS IAM Temporary Session Credentials generated from IAM Roles can be passed directly to the `aws-proxy-app` as Post Body Parameters additionally with the `TEMPCREDSPASSED = yes` Post Body parameter.
<br></br>