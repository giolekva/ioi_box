#!/bin/bash

# As a first argument expects csv file containing participation data.
# Each participant must have: username, contest id and password.
PARTICIPATION="$1"

while PARTICIPATION= read -r line
do
    IFS=', ' read -r -a part <<< "$line"
    python3 /cms/cmscontrib/AddParticipation.py \
    	    "${part[0]}" \
	    -c "${part[2]}" \
	    -p "${part[1]}" \
	    --bcrypt
    echo "Added participation: ${part[0]}"
done < "$PARTICIPATION"
