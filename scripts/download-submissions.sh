#!/bin/bash

yes | python3 /cms/cmscontrib/ExportSubmissions.py \
	      -c=7 \
	      --filename "{task}.{user}.{id}.{file}{ext}" \
	      "/tmp/submissions"

sleep 600
