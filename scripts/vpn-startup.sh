#! /bin/bash

# Create a TUN device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun

# Create docker user
usermod -u $PUID docker_user
groupmod -g $PGID docker_group
chown -R docker_user:docker_group /config

# Start the windscribe service

service windscribe-cli start
if [ ! $? -eq 0 ]; then
    exit 5;
fi

# Log in, and configure the service

expect /opt/scripts/vpn-login.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

expect /opt/scripts/vpn-lanbypass.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

expect /opt/scripts/vpn-protocol.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

expect /opt/scripts/vpn-port.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

expect /opt/scripts/vpn-firewall.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

# Set up the windscribe DNS server

echo "nameserver 10.255.255.1" >> /etc/resolv.conf

# Connect to the VPN

expect /opt/scripts/vpn-connect.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

# Wait for the connection to come up

i="0"
expect /opt/scripts/vpn-health-check.expect
while [[ ! $? -eq 0 ]]; do
    sleep 2
    echo "Waiting for the VPN to connect... $i"
    i=$[$i+1]
    if [[ $i -eq "10" ]]; then
        exit 5
    fi
    expect /opt/scripts/vpn-health-check.expect
done

echo "Port forward is $VPN_PORT"

# Run the setup script for the environment
bash /opt/scripts/app-setup.sh

# Run the user app in the docker container
su -w VPN_PORT -g docker_group - docker_user -c "bash /opt/scripts/app-startup.sh"

