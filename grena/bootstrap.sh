#!/bin/bash                                                                                                                                         
set -e

# export K3S_VERSION="v1.18.6+k3s1"
# export SSH_KEY="~/.ssh/id_rsa_ejoi_main"

# export NODE_1="185.212.252.108"
# export NODE_2="185.212.252.251"
# export NODE_3="185.212.252.242"
# export AGENT_1="185.212.252.160"
# export AGENT_2="185.212.252.76"
# export AGENT_3="185.212.252.77"

# export SERVER_LOCAL_IP=$NODE_1 #"192.168.25.11"


# export USER=root

# # First master
# echo "---- Installing on NODE_1"
# k3sup install \
#   --cluster \
#   --user $USER \
#   --ip $NODE_1 \
#   --ssh-key $SSH_KEY

# # Second master
# echo "---- Installing on NODE_2"
# k3sup join \
#   --server \
#   --ip $NODE_2 \
#   --ssh-key $SSH_KEY \
#   --user $USER \
#   --server-user $USER \
#   --server-ip $SERVER_LOCAL_IP

# # Third master
# echo "---- Installing on NODE_3"
# k3sup join \
#   --server \
#   --ip $NODE_3 \
#   --ssh-key $SSH_KEY \
#   --user $USER \
#   --server-user $USER \
#   --server-ip $SERVER_LOCAL_IP

# # First agent
# echo "---- Installing on AGENT_1"
# k3sup join \
#   --ip $AGENT_1 \
#   --ssh-key $SSH_KEY \
#   --user $USER \
#   --server-user $USER \
#   --server-ip $SERVER_LOCAL_IP

# # Second agent
# echo "---- Installing on AGENT_2"
# k3sup join \
#   --ip $AGENT_2 \
#   --ssh-key $SSH_KEY \
#   --user $USER \
#   --server-user $USER \
#   --server-ip $SERVER_LOCAL_IP

# # Third agent
# echo "---- Installing on AGENT_3"
# k3sup join \
#   --ip $AGENT_3 \
#   --ssh-key $SSH_KEY \
#   --user $USER \
#   --server-user $USER \
#   --server-ip $SERVER_LOCAL_IP

# echo "---- DONE INSTALLING k3s"

# export KUBECONFIG=`pwd`/kubeconfig
# ./kubectl get nodes -A
# ./kubectl version

# echo "---- Uninstalling traefik"
# helm uninstall traefik --namespace=kube-system

# echo "-- Annotating nodes"
# ./kubectl label node n01 ejoi-role=data
# ./kubectl label node n02 ejoi-role=data
# ./kubectl label node n03 ejoi-role=data
# ./kubectl label node n04 ejoi-role=tester
# ./kubectl label node n05 ejoi-role=tester
# ./kubectl label node n06 ejoi-role=tester
# ./kubectl taint nodes n04 key=value:NoSchedule
# ./kubectl taint nodes n05 key=value:NoSchedule
./kubectl taint nodes n06 key=value:NoSchedule

echo "---- Installing longhorn"
./kubectl create namespace longhorn-system
helm install longhorn ./longhorn/chart/ --namespace longhorn-system

# TODO: templetize db-creds.yaml
POSTGRES_USER=cmsuser
POSTGRES_PASSWORD=cmsuser
POSTGRES_DB=cmsdb

echo "---- INSTALLING postgresql"
./kubectl create namespace db
helm install --namespace=db postgres bitnami/postgresql-ha \
     --set global.storageClass=longhorn \
     --set global.postgresql.username=${POSTGRES_USER} \
     --set global.postgresql.password=${POSTGRES_PASSWORD} \
     --set global.postgresql.database=${POSTGRES_DB} \
     --set fullnameOverride=db \
     --set postgresql.replicaCount=1 \
     --set persistence.size=5Gi \
     --set postgresql.nodeSelector."ejoi-role"=data \
     --set pgpool.nodeSelector."ejoi-role"=data 


# echo "---- Generating CMS configuration"
# CMS_TOKEN=8e045a51e4b102ea803c06f92841a1fb

# CONF_TEMPLATE_FILE=$(pwd)/../config/cms.conf.template
# CONF_FILE=$(pwd)/../config/cms.conf
# cp -f "${CONF_TEMPLATE_FILE}" "${CONF_FILE}"

# sed -i -e "s/POSTGRES_USER/${POSTGRES_USER}/g" "${CONF_FILE}"
# sed -i -e "s/POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/g" "${CONF_FILE}"
# sed -i -e "s/POSTGRES_DB/${POSTGRES_DB}/g" "${CONF_FILE}"
# sed -i -e "s/CMS_TOKEN/${CMS_TOKEN}/g" "${CONF_FILE}"


# echo "---- Building and pushing Docker image"
# docker build --tag=giolekva/ioi-cms:latest --file=../Dockerfile ../
# docker push giolekva/ioi-cms:latest


echo "---- Installing CMS"
./kubectl create namespace cms
./kubectl apply -f ../k8s/db-creds.yaml
./kubectl apply -f ../k8s/db-init.yaml
./kubectl apply -f ../k8s/cms.yaml
./kubectl apply -f ../k8s/service.yaml
