#! /bin/bash

# Create a TUN device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun

# Create docker user
groupadd -g $PGID -r docker_group
useradd -u $PUID -r -g docker_group docker_user

service windscribe-cli start
if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/vpn-login.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/vpn-lanbypass.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/vpn-protocol.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/vpn-port.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/vpn-firewall.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

echo "nameserver 10.255.255.1" >> /etc/resolv.conf

/opt/scripts/vpn-connect.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

# Run the user app in the docker container
su -g docker_group - docker_user -c "/opt/scripts/app-startup.sh"

