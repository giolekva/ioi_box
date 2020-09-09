#!/bin/bash

USERS="$1"

while USERS= read -r line
do
    IFS=',' read -r -a user <<< "$line"
    if [ -z "${user[0]}" ]
    then
	continue
    fi    
    python3 /cms/cmscontrib/RemoveUser.py \
    	   "${user[2]}"
done < "$USERS"
