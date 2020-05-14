#!/bin/bash

# Script to initialize the CMS database and add the admin and dummy user. 
# This script is copied to the docker image and run inside container.

set -e

echo "Initializing database ..."
cmsInitDB

echo "Creating an admin ..."
cmsAddAdmin -p admin admin

echo "Creating an ordinary user ..."
cmsAddUser -p password Dummy User user
 
