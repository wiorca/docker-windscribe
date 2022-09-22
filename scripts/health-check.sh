#! /bin/bash

# Verify the network is up

bash /opt/scripts/vpn-health-check.sh

if [ ! $? -eq 0 ]; then
    exit 1;
fi

# Check the app health

bash /opt/scripts/app-health-check.sh

if [ ! $? -eq 0 ]; then
    exit 1;
fi

exit 0

