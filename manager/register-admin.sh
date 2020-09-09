#!/bin/bash

set -e

export ADMIN_USER=$1
export ADMIN_PASSWORD=$2

echo "Cleaning up old run"
./kubectl -n cms delete pod/register-admin

echo "Starting pod"
envsubst < ../k8s/register-admin.yaml | kubectl apply -f -
while [[ $(kubectl -n cms get pods register-admin -o 'jsonpath={..status.phase}') != "Succeeded" ]]; do
    echo "Waiting for pod"
    sleep 1
done

echo "Logs"
./kubectl -n cms logs register-admin
