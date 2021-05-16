#!/bin/bash

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | (grep admin-user || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}'
