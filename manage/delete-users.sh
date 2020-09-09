#!/bin/bash

set -e

export USERS_FILE=$1

echo "Cleaning up old run"
./kubectl -n cms delete pod/delete-users
./kubectl -n cms delete configmap/contestants

echo "Creating users config file"
./kubectl -n cms create configmap contestants --from-file=$USERS_FILE

echo "Starting pod"
envsubst < ../k8s/delete-users.yaml | ./kubectl apply -f -
while [[ $(kubectl -n cms get pods delete-users -o 'jsonpath={..status.phase}') != "Succeeded" ]]; do
    echo "Waiting for pod"
    sleep 1
done

echo "Logs"
./kubectl -n cms logs delete-users
