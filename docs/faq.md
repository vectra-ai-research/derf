# F.A.Q.

## What permissions do I need to run DeRF?

DeRF separates the permissions required to deploy the infrastructure from the permissions required to execute an attack.

### Deployment Permissions
See [here](Deployment/deployment-permissions.md) for AWS policy detailing the permissions required to in AWS and GCP to deploy the DeRF.


### End User Execution Permissions
See [here](user-guide/attack-execution-access-control.md) for detailed instructions on the permissions required in GCP to execute attacks.

## How does the DeRF persist state?

The DeRF uses a remote backend for its Terraform configurations and as such, a S3 bucket is required to initialize and deploy The DeRF.  See `./env-prod/TEMPLATE.conf`.    
This is a requirement because AWS Access Keys are generated during DeRF deployment and the Access Key Secret value will persist in terraform state.  Its better these secrets persists in an encrypted S3 bucket with appropriate access controls rather than the operators local machine. 

## How can I add my own attack techniques to the DeRF?

Review the documentation at `docs/user-guide/aws-attack-creation.md` for instructions on creating your own attacks targeting AWS resources.  See sample attack modules under the `attacks-internal` directory.


## Can I use the DeRF to execute attack techniques against my own infrastructure?

- AWS: This tool spins up DeRF specific resources in specified AWS account in order for the attack techniques to operate on.  Within each module you can see the required resources in the `infra.tf` file.  If you wanted the attack technique modules to target different infrastructure it would require some terraform surgery.  
    1. Comment out the contents of the `infra.tf` file.
    2. Within the `local.tf` file, replace the values of the local variables with the hardcoded values from your BYO Infrastructure.
    3. Comment out the variables from the infrastructure no longer used in the `variables.tf` file.

## How do I destroy the DeRF Infrastructure?
All deployed resources across both AWS and GCP will be removed with terraform.
From the `env-prod/` directory:
``` tf
terraform destroy -var-file=derf.tfvars
```

## Is this a good pentesting tool?
Not really. The DeRF targets resources which are created and managed by the tool, it doesn't make a good tool for targeting arbitrary, un-managed infrastructure. If you are looking for a good pentesting tool for AWS, checkout [pacu](https://rhinosecuritylabs.com/aws/pacu-open-source-aws-exploitation-framework/), for Azure, checkout [Microburst](https://github.com/NetSPI/MicroBurst) or the [MAAD Framework](https://github.com/vectra-ai-research/MAAD-AF)
