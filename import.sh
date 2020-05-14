#!/bin/bash

set -e

ZIP_URL=$1
CONTEST_NAME_OG=$(basename $ZIP_URL .zip)
CONTEST_NAME=$(echo ${CONTEST_NAME_OG} | sed -e "s/_/-/g")

IMPORT_YAML_TMPL=scripts/import-contest.yaml.tmpl
IMPORT_YAML=/tmp/import-contest.yaml
cp "${IMPORT_YAML_TMPL}" "${IMPORT_YAML}"
sed -i -e "s/CONTEST_NAME/${CONTEST_NAME}/g" "${IMPORT_YAML}"
sed -i -e "s#ZIP_URL#${ZIP_URL}#g" "${IMPORT_YAML}"

KUBECONFIG=~/.k3s.kubeconfig.ejoi kubectl -n cms apply -f ${IMPORT_YAML}
