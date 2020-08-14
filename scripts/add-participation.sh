#!/bin/bash

PARTICIPATION="$1"

while PARTICIPATION= read -r line
do
    IFS=', ' read -r -a part <<< "$line"
    python3 /cms/cmscontrib/AddParticipation.py \
    	    "${part[0]}" \
	    -c "${part[1]}"
done < "$PARTICIPATION"
