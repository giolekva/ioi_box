#!/bin/bash

./kubectl -n $1 exec --stdin --tty $2 -- /bin/bash
