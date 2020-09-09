#!/bin/bash                                                                                                                                         
set -e

export USER=root

# export K3S_VERSION="v1.18.6+k3s1"
export SSH_KEY="~/.ssh/id_rsa_ejoi_main"

export NODE_1="185.212.252.108"
export NODE_2="185.212.252.251"
export NODE_3="185.212.252.242"
export NODE_4="185.212.252.160"
export NODE_5="185.212.252.76"
export NODE_6="185.212.252.77"
export NODE_7="185.212.252.138"
export NODE_8="185.212.252.177"
export NODE_9="185.212.252.59"
export NODE_10="185.212.252.55"
export NODE_11="185.212.252.155"
export NODE_12="185.212.252.212"
export NODE_13="185.212.252.74"
export NODE_14="185.212.252.238"
export NODE_15="185.212.252.201"
export NODE_16="185.212.252.110"
export NODE_17="185.212.252.190"
export NODE_18="185.212.252.85"
export NODE_19="185.212.252.221"
export NODE_20="185.212.252.192"
export NODE_21="185.212.252.200"
export NODE_22="185.212.252.61"
export NODE_23="185.212.252.67"
export NODE_24="185.212.252.223"
export NODE_25="185.212.252.208"

export MASTER=$NODE_2

export SERVICES=($NODE_1 $NODE_3)
export TESTERS=($NODE_13 $NODE_14 $NODE_15 $NODE_16 $NODE_17 $NODE_18 $NODE_19 $NODE_20 $NODE_21 $NODE_22)

export DISABLE_VA_SPACE="
kernel.randomize_va_space = 0
"

echo "---- Installing on k3s master"
k3sup install \
  --cluster \
  --user $USER \
  --ip $MASTER \
  --ssh-key $SSH_KEY

for i in "${SERVICES[@]}";
do
    echo "#### Processing $i"

    echo "---- Installing k3s"
    k3sup join \
    	  --ip $i \
    	  --ssh-key $SSH_KEY \
    	  --user $USER \
    	  --server-user $USER \
    	  --server-ip $MASTER \

    echo "---- Preparing for longhorn"
    ssh -i $SSH_KEY $USER@$i apt-get install open-iscsibash
    
    echo "#### Done with $i"
done

for i in "${TESTERS[@]}";
do
    echo "#### Processing $i"

    echo "---- Installing k3s"
    k3sup join \
    	  --ip $i \
    	  --ssh-key $SSH_KEY \
    	  --user $USER \
    	  --server-user $USER \
    	  --server-ip $MASTER \
    	  --k3s-extra-args '--node-taint key=value:NoSchedule --node-label ejoi-role=tester'

    echo "---- Preparing for isolate"
    scp -i $SSH_KEY rc.local $USER@$i:/etc/rc.local
    scp -i $SSH_KEY rc-local.service $USER@$i:/etc/systemd/system/rc-local.service
    ssh -i $SSH_KEY $USER@$i bash -c "'
set -e

echo "$DISABLE_VA_SPACE" >> /etc/sysctl.conf
chmod +x /etc/rc.local
systemctl start rc-local.service
systemctl status rc-local.service
shutdown -r
'"    
    
    echo "#### Done with $i"
done

export KUBECONFIG=$(pwd)/kubeconfig

echo "---- Creating Kubernetes admin user"
./kubectl apply -f ../k8s/admin-user.yaml

echo "---- Installing Kubernetes dashboard"
./kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml


echo "---- Installing longhorn"
kubectl create namespace longhorn-system
helm install longhorn ./longhorn/chart/ --namespace longhorn-system

### CMS

# TODO: templetize db-creds.yaml
POSTGRES_USER=cmsuser
POSTGRES_PASSWORD=cmsuser
POSTGRES_DB=cmsdb

POSTGRES_REPMGR_USER=repmgr
POSTGRES_REPMGR_PASSWORD=repmgrpsswd
POSTGRES_REPMGR_DB=repmgrdb


echo "---- Installing postgresql"
./kubectl create namespace db
#helm repo add bitnami https://charts.bitnami.com/bitnami
helm install --namespace=db postgres bitnami/postgresql-ha \
     --set global.storageClass=longhorn \
     --set global.postgresql.username=${POSTGRES_USER} \
     --set global.postgresql.password=${POSTGRES_PASSWORD} \
     --set global.postgresql.database=${POSTGRES_DB} \
     --set global.postgresql.repmgrUsername=${POSTGRES_REPMGR_USER} \
     --set global.postgresql.repmgrPassword=${POSTGRES_REPMGR_PASSWORD} \
     --set global.postgresql.repmgrDatabase=${POSTGRES_REPMGR_DB} \
     --set fullnameOverride=db \
     --set postgresql.replicaCount=1 \
     --set persistence.size=80G \
     --set postgresql.resources.requests.cpu="3500m" \
     --set postgresql.resources.requests.memory="6Gi" \
     --set pgpool.resources.requests.cpu="1500m" \
     --set pgpool.resources.requests.memory="2Gi" \
     --set pgpool.maxPool=1 \
     --set pgpool.numInitChildren=1 \
     --set postgresql.repmgrConnectTimeout=500 \
     --set postgresql.repmgrReconnectAttempts=100 \
     --set pgpool.nodeSelector."ejoi-role"=back \
     --set postgresql.nodeSelector."ejoi-role"=back \
     --set pgpool.replicaCount=1 \
     --set volumePermissions.enabled=true \
     --set postgresql.extendedConf.max_connections=500 \
     --set postgresql.extendedConf.shared_buffers=2GB \
     --set postgresql.extendedConf.effective_cache_size=2GB \
     --set postgresql.initdbScripts."init\.sql"="ALTER SCHEMA public OWNER TO cmsuser; GRANT SELECT ON pg_largeobject TO cmsuser;"

echo "---- Generating CMS configuration"
CMS_TOKEN=8e045a51e4b102ea803c06f92841a1fb

CONF_TEMPLATE_FILE=$(pwd)/../config/cms.conf.template
CONF_FILE=$(pwd)/../config/cms.conf
cp -f "${CONF_TEMPLATE_FILE}" "${CONF_FILE}"

sed -i -e "s/POSTGRES_USER/${POSTGRES_USER}/g" "${CONF_FILE}"
sed -i -e "s/POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/g" "${CONF_FILE}"
sed -i -e "s/POSTGRES_DB/${POSTGRES_DB}/g" "${CONF_FILE}"
sed -i -e "s/CMS_TOKEN/${CMS_TOKEN}/g" "${CONF_FILE}"



echo "---- Building and pushing Docker image"
docker build --tag=giolekva/ioi-cms:latest --file=../Dockerfile ../
docker push giolekva/ioi-cms:latest

echo "---- Installing CMS"
kubectl create namespace cms
kubectl apply -f ../k8s/db-creds.yaml
kubectl apply -f ../k8s/db-init.yaml
kubectl apply -f ../k8s/cms.yaml
kubectl apply -f ../k8s/service.yaml
