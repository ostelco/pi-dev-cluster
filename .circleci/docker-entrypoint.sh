#!/bin/sh

##
## The intent if this script is to be a wrapper for other scripts,
## that is run as activated from a particular service account.   To run
## this script set the CLUSTER environment variable to either "dev" or "prod"
## depending on which of the clusters are being addressed.   Also ensure that
## either  the PI_DEV_GOOGLE_CREDENTIALS or PI_PROD_GOOGLE_CREDENTIALS variables
## are set.

## NOTE:  After having run this script will have a leave the credentials
##        stored in the PI_*_GOOGLE_CREDENTIALS environment variable in the
##        file /tmp/credentials.json.    It would be prudent to
##        ensure that this file is deleted after use, but at this time it
##        isn't.
##

TEMP_CREDENTIALS_FILE=/tmp/credentials.json

# Populate the temporary credentials file
if [[ "$CLUSTER" = "dev" ]] && [[ ! -z "${PI_DEV_GOOGLE_CREDENTIALS}" ]]; then
  echo $PI_DEV_GOOGLE_CREDENTIALS > $TEMP_CREDENTIALS_FILE
elif [[ "$CLUSTER" = "prod" ]] && [[ ! -z "${PI_PROD_GOOGLE_CREDENTIALS}" ]]; then
  echo $PI_PROD_GOOGLE_CREDENTIALS > $TEMP_CREDENTIALS_FILE
else
  echo "Appropriate Google credentials have not been set in the environment. Aborting!"
  exit 1
fi

echo "Successfully populated $TEMP_CREDENTIALS_FILE"

gcloud auth activate-service-account --key-file "$TEMP_CREDENTIALS_FILE"

if [ $? != 0 ]; then
  echo "FAILED to authenticate to Google cloud. Aborting!"
  exit 1
else
  echo "Successfully authenticated to Google cloud."
fi

echo "Executing command as authenticated into google cloud: $@"

exec "$@"

