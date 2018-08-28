# Google GKE DEV cluster

[![CircleCI](https://circleci.com/gh/ostelco/infra/tree/master.svg?style=svg&circle-token=73f413df2d44cad888b45fe96d7a9d8f6898fc02)](https://circleci.com/gh/ostelco/infra/tree/dev)

Terraform config and Circleci pipeline to build and maintain Kubernetes cluster

## Pipeline docs

The following docs are available:
- [circleci-pipeline](docs/circleci-pipeline.md)
- [terraform-scripts](docs/terraform-scripts.md)


## Notes:

- The Circleci pipeline runs a plan step, waits for human approval before it applies changes.
- Some changes may cause a cluster recreation. **Inspect** the plan step results before you approve applying the changes.
- While the Terraform config can be run from any machine. It's **strongly discouraged** to do so to avoid Terraform state locking. 
  - Should a locking situation occur, then the solution would be to look in the [terraform state bucket](https://console.cloud.google.com/storage/browser/pi-ostelco-dev-terraform-state/clusters/dev/state/?project=pi-ostelco-dev&authuser=2&organizationId=7215087637) and delete the lock file.
- Another reason for not using terraform locally is that there could be version differences between the terraform running on your workstation and the one running on the CI.  These different versions use different formats in their state files, so running both towards the same state (in the same bucket) will cause inconsistencies and therefore failure.
- How to update terraform 
- To run terraform script from your machine (discouraged, see above :-):
   - Get the service account keys from the [bucket](https://console.cloud.google.com/storage/browser/pi-ostelco-dev-service-accounts-keys?project=pi-ostelco-dev&authuser=2&organizationId=7215087637) it is stored (or generate a new one and put it where you like )