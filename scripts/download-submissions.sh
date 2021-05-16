#!/bin/bash

yes | python3 /cms/cmscontrib/ExportSubmissions.py \
	      -c $1 \
	      --filename "{task}-{user}-{id}-{file}{ext}" \
	      "/tmp/contest_$1"
echo "ALL SUBMISSIONS DOWNLOADED"

sleep 120
