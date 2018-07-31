# Google GKE DEV cluster

Terraform config and Circleci pipeline to build and maintain Kubernetes cluster

## Notes:

- The DEV cluster config is managed in the `dev` branch.
- The Circleci pipeline runs a plan step, waits for human approval before it applies changes.
- Some changes may cause a cluster recreation. **Inspect** the plan step results before you approve applying the changes.
- While the Terraform config can be run from any machine. It's **strongly discouraged** to do so to avoid Terraform state locking. 
- By default, the pipeline pushes cluster certificates into a GCS bucket `pi-ostelco-dev-k8s-key-store` (for dev) & `pi-ostelco-prod-k8s-key-store` (for prod) . You can override this bucket by setting an environment variable in Circleci called `PI_DEV_K8S_KEY_STORE_BUCKET` (for dev) or `PI_PROD_K8S_KEY_STORE_BUCKET` (for prod) with the format `gs://<bucket-name>`
