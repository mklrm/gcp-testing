#!/bin/fish
set -x
# Based on https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-ansible/blob/master/tutorial/tutorial.md
export PROJECT_ID="playground-s-11-b692b9f7"
#export SERVICE_ACCOUNT_ID="cli-service-account-1@playground-s-11-9c7ff3ce.iam.gserviceaccount.com"
export SERVICE_ACCOUNT_EMAIL="cli-service-account-1@playground-s-11-b692b9f7.iam.gserviceaccount.com"

gcloud config set project $PROJECT_ID
#gcloud iam service-accounts keys create $PWD/misc/key-file --iam-account=$SERVICE_ACCOUNT_EMAIL
#export GCP_SERVICE_ACCOUNT_FILE=$PWD/misc/key-file
cp $PWD/misc/inventory.gcp.template.yaml $PWD/misc/inventory.gcp.yaml
sed -i "s/ENTER_PROJECT_NAME/$PROJECT_ID/g" $PWD/misc/inventory.gcp.yaml

## Create an ssh agent to simplify repeated connections via ansible, and add the SSH key
#ssh-agent
#ssh-add PATH_TO_SSH_PUB_KEY

# TODO Wrangle ansible in to using IAP, see:
# https://binx.io/2021/03/10/how-to-tell-ansible-to-use-gcp-iap-tunneling/

