#! /bin/bash

/opt/scripts/vpn-health-check.expect

if [ ! $? -eq 0 ]; then
    exit 1;
fi

/opt/scripts/app-health-check.sh

if [ ! $? -eq 0 ]; then
    exit 1;
fi

exit 0

