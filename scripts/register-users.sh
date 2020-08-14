#!/bin/bash

# As a first argument expects csv file containing user data.
# Each user must have: first name, last name, username, password and email.
USERS="$1"

while USERS= read -r line
do
    IFS=', ' read -r -a user <<< "$line"
    python3 /cms/cmscontrib/AddUser.py \
    	   "${user[0]}" \
    	   "${user[1]}" \
    	   "${user[2]}" \
    	   -p "${user[3]}" \
    	   -e "${user[4]}" \
    	   --bcrypt
done < "$USERS"
