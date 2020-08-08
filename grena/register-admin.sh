#!/bin/bash

set -e

export ADMIN_USER=$1
export ADMIN_PASSWORD=$2

envsubst < ../k8s/register-admin.yaml | kubectl apply -f -
