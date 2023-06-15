---
title: DeRF Execution User Permissions
---


## DeRF Execution Permissions
The permissions assigned to the `derf-execution-users` or the `DeRF-Default-User` are NOT documented here.  Rather, this is a guide as to where you can find those permissions and how to update them.

### Execution User Group Membership
Both User 01 and 02 are members of the `derf-execution-users` group, allowing them to perform all the same attack techniques outlined in the DeRF.

### ^^DeRF Execution User^^ - Policy Assignments
Every attack technique is responsible for creating a policy containing the permissions needed to execute the attack and assigning it to the  `derf-execution-users` group.
The policy and group assignments are found in the `iam-permissions.tf` file within the `/attack-techniques/aws/permissions-required` module.   

### ^^DeRF Default^^ User - Policy Assignments
If an attack technique needs the default user to reverse a state changing action or perform another task that should not be attributed to the execution users, the module is responsible for creating a policy containing the necessary permissions and attaching it to the `DeRF-Default-User`.
The policy and group assignments are found in the `iam-permissions.tf` file within the `/attack-techniques/aws/permissions-required` module.    
