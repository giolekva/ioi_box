#!/bin/bash

set -e

export USERS_FILE=$1

./kubectl -n cms create configmap contestants --from-file=$USERS_FILE
envsubst < ../k8s/register-users.yaml | ./kubectl apply -f -

