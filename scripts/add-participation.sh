#!/bin/bash

PARTICIPATION="$1"

while PARTICIPATION= read -r line
do
    IFS=', ' read -r -a part <<< "$line"
    python3 /cms/cmscontrib/AddParticipation.py \
    	    "${part[0]}" \
	    -c "${part[3]}" \
	    -p "${part[1]}" \
	    --bcrypt
    #    	    -t "${part[2]}" \
done < "$PARTICIPATION"
