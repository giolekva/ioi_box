#!/bin/bash

set -e

export PARTICIPATION_FILE=$1

echo "Cleaning up old run"
./kubectl -n cms delete pod/add-participation
./kubectl -n cms delete configmap/participation

echo "Creating users config file"
./kubectl -n cms create configmap participation --from-file=$PARTICIPATION_FILE

echo "Starting pod"
envsubst < ../k8s/add-participation.yaml | ./kubectl apply -f -
while [[ $(kubectl -n cms get pods add-participation -o 'jsonpath={..status.phase}') != "Succeeded" ]]; do
    echo "Waiting for pod"
    sleep 1
done

echo "Logs"
./kubectl -n cms logs add-participation
