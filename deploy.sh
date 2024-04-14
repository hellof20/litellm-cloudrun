#!/bin/bash

#export PROJECT_ID=speedy-victory-336109
#export REGION=asia-east1
export IMAGE=litellm/litellm:v1.35.4

if [ ! $PROJECT_ID ]; then
    echo "please set PROJECT_ID"
    exit 1
fi

if [ ! $REGION ]; then
    echo "please set REGION"
    exit 1
fi

echo "Create service account for litellm proxy ... "
gcloud iam service-accounts create litellmsa \
    --description="Service account for litellm" \
    --display-name="litellmsa" \
    --project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:litellmsa@${PROJECT_ID}.iam.gserviceaccount.com \
    --role='roles/aiplatform.user'  \
    --condition=None \
    --quiet > /dev/null

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:litellmsa@${PROJECT_ID}.iam.gserviceaccount.com \
    --role='roles/secretmanager.secretAccessor' \
    --condition=None \
    --quiet > /dev/null

echo "Create secret from your config.yaml"
gcloud secrets create litellm-config \
    --replication-policy="automatic" \
    --data-file="config.yaml"

echo "Deploy litellm proxy on CLoud Run"
gcloud run deploy litellm-proxy-001 --image=${IMAGE} \
    --max-instances=8 \
    --min-instances=1 \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --service-account litellmsa@${PROJECT_ID}.iam.gserviceaccount.com \
    --cpu=1 \
    --memory=512Mi \
    --concurrency=4 \
    --port=4000 \
    --allow-unauthenticated \
    --timeout=90 \
    --update-secrets=/app/config.yaml=litellm-config:latest \
    --args="--config","/app/config.yaml"


# gcloud secrets versions add litellm-config --data-file="config.yaml"
# gcloud run services update litellm-proxy-001 --region=${REGION} --project=${PROJECT_ID} --set-secrets=/app/config.yaml=litellm-config:latest
