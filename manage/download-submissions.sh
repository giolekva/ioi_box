#!/bin/bash

export CONTEST_ID=$1

echo "Cleaning up old run"
./kubectl delete pod/download-submissions

set -e

echo "Starting pod"
envsubst < ../k8s/download-submissions.yaml | ./kubectl apply -f -
while [[ $(kubectl get pods download-submissions -o 'jsonpath={..status.phase}') != "Running" ]]; do
    echo "Waiting for pod to start running"
    sleep 1
done
echo "Waiting to get submissions"
while [[ 0 -eq 0 ]]; do
    kubectl logs download-submissions > download_logs
    cat download_logs | grep "ALL SUBMISSIONS DOWNLOADED" > download_logs_filtered
    if [[ $(wc -l <download_logs_filtered) -gt 0 ]]; then
	break
    fi
    echo "Waiting for pod"
    sleep 1
done

mkdir "submissions_${CONTEST_ID}"
kubectl cp "download-submissions:/tmp/contest_${CONTEST_ID}" "submissions_${CONTEST_ID}"

echo "Logs"
cat download_logs
rm download_logs*
