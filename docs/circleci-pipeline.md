# Circleci Pipeline

The pipeline manages the GKE clusters for both **DEV** and **PROD** environments.

## Google Projects

For complete separation and better access control, the **DEV** and **PROD** clusters are created in two different Google cloud projects. Namely, `pi-ostelco-dev` & `pi-ostelco-prod`.

The production cluster (and it's project) will only be accessible by admins or other team members who are delegated to cover for admins.

## Branches

There are two long lived branches (they are not meant to be merged): 

- dev : the **DEV** cluster is managed from this branch
- master : the **PROD** cluster is managed from this branch.

## Circleci config

Circleci [config](../.circleci/config.yml) is available under `.circleci/`

### the pipeline steps

The steps are the same for both the **DEV** & **PROD** clusters. 

`run terraform plan` --> `wait for a manual approval of the plan in circleci` --> `if approved, apply the changes with terraform plan and copy/update cluster certificates and keys to a Google bucket`


### circleci docker image

The docker image used in the circleci pipeline needs the following tools:

- Terraform
- gcloud

It is created and pushed to Google Container Registry (GCR) manually. The image is called: `eu.gcr.io/pi-ostelco-dev/terraform-gcloud:11.7` where `11.7` is the Terraform version.  It is created with a [dockerfile](../.circleci/Dockerfile) and has an [entrypoint script](../.circleci/docker-entrypoint.sh) which reads Google credentials from environment variables, stores it inside the container in `/tmp/credentials.json` and authenticates to Google Cloud using it.

### other CI/CD scripts

- [store_cluster_certs.sh](../.circleci/store_cluster_certs.sh) : copies the cluster certificates and keys which are retrieved by Terraform output to a Google cloud storage bucket.

### circleci environment variables

| variable                     | description                                                                                                                                                                                                  | optional |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| PI_DEV_GOOGLE_CREDENTIALS    | Google cloud service account credentials from the **pi-ostelco-dev** project which has the following permissions: Compute Instance Admin (v1), Kubernetes Engine Admin, Service Account User, Storage Object Admin  | No       |
| PI_PROD_GOOGLE_CREDENTIALS   | Google cloud service account credentials from the **pi-ostelco-prod** project which has the following permissions: Compute Instance Admin (v1), Kubernetes Engine Admin, Service Account User, Storage Object Admin | No       |
| DEV_CLUSTER_PASSWORD         | the admin password for the DEV cluster                                                                                                                                                                      | No       |
| PROD_CLUSTER_PASSWORD        | the admin password for the PROD cluster                                                                                                                                                                     | No       |
| PI_DEV_K8S_KEY_STORE_BUCKET  | The bucket for storing DEV cluster certificates and keys. The format is: `gs://bucket-name`. The bucket should pre-exist in the **pi-ostelco-dev** project. If not specified, the default is: `gs://pi-ostelco-dev-k8s-key-store`                    | Yes      |
| PI_PROD_K8S_KEY_STORE_BUCKET | The bucket for storing PROD cluster certificates and keys. The format is: `gs://bucket-name`.The bucket should pre-exist in the **pi-ostelco-prod** project. If not specified, the default is: `gs://pi-ostelco-prod-k8s-key-store`                   | Yes      |