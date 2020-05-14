#!/bin/bash

# Script to import a zip-ed contest directory.
# This script is copied to the docker image and run inside container.

set -e

ZIP_URL=$1
CONTEST_NAME=$2
ZIP_FILE=/tmp/contest/${CONTEST_NAME}.zip
CONTEST_DIR=/tmp/contest/${CONTEST_NAME}

rm -rf ${ZIP_FILE}
rm -rf ${CONTEST_DIR}
mkdir -p /tmp/contest

echo "Downloading ${ZIP_URL} to ${ZIP_FILE}"
echo "wget -c -O ${ZIP_FILE} ${ZIP_URL}"
wget -c -O ${ZIP_FILE} ${ZIP_URL}

echo "Unpacking ..."
mkdir -p "${CONTEST_DIR}"
unzip "${ZIP_FILE}" -d "${CONTEST_DIR}"

echo "Importing ..."
cd "${CONTEST_DIR}"
cmsImportContest --update-contest --import-tasks --update-tasks .
