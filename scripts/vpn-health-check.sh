#! /bin/bash

# Verify windscribe is running

WINDSCRIBE=$(pgrep windscribe | wc -l )
if [[ ${WINDSCRIBE} -ne 1 ]]
then
	echo "Windscribe process not running"
	exit 1
fi

# Verify windscribe service is happy

/opt/scripts/vpn-health-check.expect

if [ ! $? -eq 0 ]; then
    exit 1;
fi

# Veryify we can ping out

ping -c 1 google.com
STATUS=$?
if [[ ${STATUS} -ne 0 ]]
then
    echo "Network is down"
    exit 1
fi

echo "Network is up"

exit 0

