#!/bin/bash
# This script extracts the keys/certs needed to authenticate to the cluster endpoint
# These secrets are needed when configuring kubectl manually (without the magical gcloud command)
# They will be used by Helmsman to connect to the cluster, and therefore need to be always updated in the GCS bucket
# each time terraform is applied.

# This script will be executed as part of the circleci workflow after terraform cluster script is applied.

# defining the bucket where the secrets are stored.
BUCKET=gs://pi-ostelco-dev-k8s-key-store

# defining the prefix that identifies which cluster the keys belong to.
if [ "$CLUSTER" = "dev" ]; then
   prefix="dev_cluster_"
elif [ "$CLUSTER" = "prod" ]; then
   prefix="prod_cluster_"
fi


# saving the scecrets into files
echo "Importing keys from terraform into local files for [ $CLUSTER ] cluster ... "

mkdir keys
echo $(terraform output "$prefix"client_certificate) | base64 -d > keys/"$prefix"client_certificate.crt
echo $(terraform output "$prefix"client_key) | base64 -d > keys/"$prefix"client_key.key
echo $(terraform output "$prefix"cluster_ca_certificate) | base64 -d > keys/"$prefix"cluster_ca.crt

# push secrets to GCS and cleanup the local file system
if [[ -s keys/"$prefix"client_certificate.crt && -s keys/"$prefix"client_key.key && -s keys/"$prefix"ca.crt ]];then
  echo "Pushing keys to GCS ... "
  if ! gsutil cp -r keys  ${BUCKET}; then
    exit 1
  else
    echo "Cleaning up local file system ... "
    if ! rm -r keys; then
      echo "Something went wrong during the local file system cleanup. Please clean it up manually."
    else
      echo "Pushed [ $CLUSTER ] cluster keys successfully to GCS and cleaned local file system."
    fi
  fi

else
  echo "Something went wrong with reading terraform output variables! The files (or some of them) are empty. Deleting local files and aborting!"
  rm -r keys
  exit 1
fi