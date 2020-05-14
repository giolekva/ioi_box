# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --no-deploy traefik" K3S_KUBECONFIG_MODE="644" sh

# scp -i ~/.ssh/id_rsa_grena root@217.147.226.151:/etc/rancher/k3s/k3s.yaml ~/.k3s.kubeconfig.ejoi
# sed -i -e 's/127\.0\.0\.1/217.147.226.151/g' ~/.k3s.kubeconfig.ejoi


POSTGRES_USER=cmsuser
POSTGRES_PASSWORD=cmsuser
POSTGRES_DB=cmsdb

# export KUBECONFIG=/Users/lekva/.k3s.kubeconfig.ejoi
# helm install --namespace=cms prostgres bitnami/postgresql-ha \
#      --set global.storageClass=local-path \
#      --set global.postgresql.username=${POSTGRES_USER} \
#      --set global.postgresql.password=${POSTGRES_PASSWORD} \
#      --set global.postgresql.database=${POSTGRES_DB} \
#      --set fullnameOverride=db \
#      --set postgresql.replicaCount=1 \
#      --set persistence.size=1Gi


printf -- "Generating CMS configuration...\n"
CMS_TOKEN=8e045a51e4b102ea803c06f92841a1fb

CONF_TEMPLATE_FILE=$(pwd)/config/cms.conf.template
CONF_FILE=$(pwd)/config/cms.conf
cp -f "${CONF_TEMPLATE_FILE}" "${CONF_FILE}"

sed -i -e "s/POSTGRES_USER/${POSTGRES_USER}/g" "${CONF_FILE}"
sed -i -e "s/POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/g" "${CONF_FILE}"
sed -i -e "s/POSTGRES_DB/${POSTGRES_DB}/g" "${CONF_FILE}"
sed -i -e "s/CMS_TOKEN/${CMS_TOKEN}/g" "${CONF_FILE}"


