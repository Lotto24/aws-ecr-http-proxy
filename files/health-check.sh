#!/bin/sh
wget localhost:PORT/healthz -q -O - > /dev/null 2>&1
