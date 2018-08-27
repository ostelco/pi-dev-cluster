#!/bin/sh

###
### This script extracts the keys/certs needed to authenticate to the
### cluster endpoint These secrets are needed when configuring kubectl
### manually (without the magical gcloud command) They will be used by
### Helmsman to connect to the cluster, and therefore need to be always
### updated in the GCS bucket each time terraform is applied.
###
### This script will be executed as part of the circleci workflow after
### terraform cluster script is applied.
###

##
## CHECKING DEPENDENCIES
##

DEPENDENCIES="gsutil"
for dep in $DEPENDENCIES; do
    if [[ -z "$(type $dep)" ]] ; then
	echo "ERROR:  dep not in path."
    fi
done


##
## CONSTANTS
##

# Defining the prefix that identifies which cluster the keys belong to.
# It can be either "dev_cluster" or "prod_cluster", and nothing else.
PREFIX="dev_cluster"

# Directory where keys are kept after being generated, and prior to
# being used.  Should be deleted after script execution, and should be
# empty when starting the script.
KEYS_DIR="keys"

##
## UTILITY FUNCTIONS FOR EXITING THE PROGRAM, AND CLEANING UP
## KEYS DIRECTORY
##

function cleanup_keys {
   echo "Cleaning up local file system ... "
   rm -fr keys && echo "Keys cleanup complete." || echo "Something went wrong during keys cleanup."
}

function bail_out {
    echo "ERROR: $1"
    cleanup_keys
    exit 1
}

##
##  MAIN FUNCTION FOR GENERATING KEYS AND STORING THEM
##  IN KEYS_DIR
##


function generate_keys {
    echo "Generating key files in $KEYS_DIR"
    # defining the bucket where the secrets are stored.
    GCS_BUCKET=gs://pi-ostelco-dev-k8s-key-store
    if [[ ! -z ${PI_DEV_K8S_KEY_STORE_BUCKET} ]] ; then
	GCS_BUCKET=${PI_DEV_K8S_KEY_STORE_BUCKET}
    fi


    if [[ "$CLUSTER" = "prod" ]]; then
	PREFIX="prod_cluster"
	GCS_BUCKET=gs://pi-ostelco-prod-k8s-key-store
	if [[ ! -z ${PI_PROD_K8S_KEY_STORE_BUCKET} ]] ; then
	    GCS_BUCKET=${PI_PROD_K8S_KEY_STORE_BUCKET}
	fi
    fi

    echo "Importing keys from terraform into local files for [ $CLUSTER ] cluster ... "
    echo "Storing them in the 'keys' subdirectory"

    if [[ -d keys ]] ; then
	echo "ERROR:  keys directory already exists, bailing out"
	exit 1
    fi

    mkdir "$KEYS_DIR" || bail_out "Could not mkdir $KEYS_DIR"

    CLIENT_CERT="${KEYS_DIR}/${PREFIX}_client_certificate.crt"
    CLIENT_KEY="${KEYS_DIR}/${PREFIX}_client_key.key"
    CLUSTER_CERT="${KEYS_DIR}/${PREFIX}_cluster_ca.crt"

    CERTS="$CLIENT_CERT $CLIENT_KEY $CLUSTER_CERT"

    echo $(terraform output ${PREFIX}_client_certificate) | base64 -d > $CLIENT_CERT
    echo $(terraform output ${PREFIX}_client_key) | base64 -d > $CLIENT_KEY
    echo $(terraform output ${PREFIX}_ca_certificate) | base64 -d > $CLUSTER_CERT


    # XXX What is this, and why is it here? It doesn't seem to be used for anything
    echo $(terraform output ${PREFIX}_endpoint) > endpoint.txt

    # Check that the certs are all there and are all readable
    for x in $CERTS ; do
        if [[ ! -r $x ]] ; then
            bail_out "Terraform variable in file $x not readable"
	fi
    done
}

##
## MAIN BODY
##

generate_keys
echo "Pushing keys in $KEYS_DIR to GCS using gsutil ... "
gsutil cp -r keys  ${GCS_BUCKET} ||  bail_out "Could not copy keys from $KEYS_DIR to GCS bucket."
cleanup_keys
