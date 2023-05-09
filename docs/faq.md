# F.A.Q.

## What permissions do I need to run DeRF?

DeRF separates the permissions required to deploy the infrastructure from the permissions required to execute an attack.

### Deployment Permissions
See `docs/Deployment/deployment-permissions.md` for AWS policy detailing the permissions required to in AWS and GCP to deploy the DeRF.


### End User Execution Permissions
See `docs/user-guide/attack-execution-access-control.md` for detailed instructions on the permissions required in GCP to execute attacks.

## How does the DeRF persist state?

DeRF uses a remote backend for its Terraform configurations.  An S3 bucket is required in order to initialize and deploy the DeRF.  See `./env-prod/TEMPLATE.conf`.  

## How can I add my own attack techniques to the DeRF?

Review the documentation at `docs/user-guide/attack-creation.md` for instructions on creating your own attacks.  See sample attack modules under the `attacks-internal` directory.

## Why didn't you use Python?

While using Python would have made some things easier, we consider it is very hard to write solid software in Python, in particular due to the lack of typing.

In addition to that, the official Hashicorp Terraform wrapper ([tfexec](https://github.com/hashicorp/terraform-exec)) used by Stratus Red Team is written in Go. There is no solid, officially-supported wrapper for Python.

Finally, distributing Go binaries is much easier and leads to a better end-user experience.

## Can I use Stratus Red Team to detonate attack techniques against my own infrastructure?

- AWS: This is currently not supported. Stratus Red Team takes care of spinning up all the required infrastructure before detonating attack techniques. Allowing to "bring your own detonation infrastructure" is on the roadmap.
- Kubernetes: Stratus Red Team does not create or destroy Kubernetes clusters for you. You point it at an existing Kubernetes cluster, and it will take care of creating any prerequisite Kubernetes resource required to detonate Kubernetes-specific attack techniques.