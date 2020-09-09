#!/bin/bash

# As a first argument expects csv file containing user data.
# Each user must have: first name, last name, username, password and email.
USERS="$1"

while USERS= read -r line
do
    IFS=',' read -r -a user <<< "$line"
    if [ -z "${user[0]}" ]
    then
	continue
    fi
    python3 /cms/cmscontrib/AddUser.py \
    	   "${user[0]}" \
    	   "${user[1]}" \
    	   "${user[2]}" \
    	   -p "${user[3]}" \
    	   -e "${user[4]}" \
    	   --bcrypt
    echo "Registered: ${user[0]} - ${user[1]} - ${user[2]}"    
done < "$USERS"
