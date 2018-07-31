# Google GKE PROD cluster

Terraform config and Circleci pipeline to build and maintain Kubernetes cluster

## Pipeline docs

The following docs are available:
- [circleci-pipeline](docs/circleci-pipeline.md)
- [terraform-scripts](docs/terraform-scripts.md)


## Notes:

- The PROD cluster config is managed in the `master` branch and the DEV cluster is managed from the `dev` branch.
- The Circleci pipeline runs a plan step, waits for human approval before it applies changes.
- Some changes may cause a cluster recreation. **Inspect** the plan step results before you approve applying the changes.
- While the Terraform config can be run from any machine. It's **strongly discouraged** to do so to avoid Terraform state locking. 

