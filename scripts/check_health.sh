#!/bin/bash

{ echo '{"__id": "foo", "__method": "echo", "__data": {"string": "bar"}}'; sleep 0.3; }  | telnet localhost 29000
exit 1
