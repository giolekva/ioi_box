#!/bin/bash

# Script to start the CMS service. 
# This script is copied to the docker image and run inside container.

set -e

echo "Starting log service ..."
cmsLogService 0 &

echo "Starting CMS services ..."
cmsResourceService -a ALL
