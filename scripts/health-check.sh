#! /bin/bash

# Verify the network is up

/opt/scripts/vpn-health-check.sh

if [ ! $? -eq 0 ]; then
    exit 1;
fi

# Check the app health

/opt/scripts/app-health-check.sh

if [ ! $? -eq 0 ]; then
    exit 1;
fi

exit 0

