# Docker Windscribe Image

## About the image

Windscribe docker container, as a base for other images.  It does not forward any ports, has onely one volume for the docker_user, and exits immediately by default.

It contains health-checking, and a framework for extending the image however you like to serve your own purposes.  It just handles connecting to windscribe for the moment, and making sure the connection remains active and secure.

This documentation format is inspired by the great people over at linuxserver.io.

## Extending the image

There are three script files placed in the /opt/scripts directory that are designed to be overwritten:

/opt/scripts/app-setup.sh

This script is designed to set up the environment for the running application. It is run as root, and should be used to prepare the environment for the running app.

/opt/scripts/app-startup.sh

This script is designed to start the user application after the connection to the VPN has been established.  This script should never exit, and will be run as docker_user:docker_group, with the UID and GID specified in PUID and GUID.

/opt/scripts/app-health-check.sh

This script will be run periodically to check the health of the container.  It MUST return 0 if the container is healthy.  Any other return value will fail.  It is called after the health check for the VPN is completed successfully.  Override as you wish.

## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=docker-windscribe \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -e WINDSCRIBE_USERNAME=username \
  -e WINDSCRIBE_PASSWORD=password \
  -e WINDSCRIBE_PROTOCOL=stealth \
  -e WINDSCRIBE_PORT=80 \
  -e WINDSCRIBE_PORT_FORWARD=9999 \
  -e WINDSCRIBE_LOCATION=US \
  -e WINDSCRIBE_LANBYPASS=on \
  -e WINDSCRIBE_FIREWALL=on \
  -e VPN_PORT=8080
  -v /location/on/host:/config \
  --dns 8.8.8.8 \
  --cap-add NET_ADMIN \
  --restart unless-stopped \
  wiorca/docker-windscribe
```


### docker-compose

Compatible with docker-compose schemas.

```
---
version: "2.1"
services:
  docker-windscribe:
    image: wiorca/docker-windscribe
    container_name: docker-windscribe
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - WINDSCRIBE_USERNAME=username
      - WINDSCRIBE_PASSWORD=password
      - WINDSCRIBE_PROTOCOL=stealth
      - WINDSCRIBE_PORT=80
      - WINDSCRIBE_LOCATION=US
      - WINDSCRIBE_LANBYPASS=on
      - WINDSCRIBE_FIREWALL=on
      - VPN_PORT=9999
    volumes:
      - /location/on/host:/config
    dns:
      - 8.8.8.8
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above).

| Parameter | Examples/Options | Function |
| :----: | --- | --- |
| PUID | 1000 | The nummeric user ID to run the application as, and assign to the user docker_user |
| PGID | 1000 | The numeric group ID to run the application as, and assign to the group docker_group |
| TZ=Europe/London | The timezone to run the container in |
| WINDSCRIBE_USERNAME | username | The username used to connect to windscribe |
| WINDSCRIBE_PASSWORD | password | The password associated with the username |
| WINDSCRIBE_PROTOCOL | stealth OR tcp OR udp | The protocol to use when connecting to windscribe, which must be on 'windscribe protocol' list |
| WINDSCRIBE_PORT | 443, 80, 53 | The port to connect to windscribe over, which must be on 'windscribe port' list for that protocol |
| WINDSCRIBE_LOCATION | US | The location to connect to, which must be on 'windscribe location' list |
| WINDSCRIBE_LANBYPASS | on, off | Allow other applications on the docker bridge to connect to this container if on |
| WINDSCRIBE_FIREWALL | on, off | Enable the windscribe firewall if on, which is recommended. |
| VPN_PORT | 9898 | The port you have configured to forward via windscribe. Not used by this container, but made available |

## Volumes

| Volume | Example | Function |
| :----: | --- | --- |
| /config | /opt/docker/docker-windscribe | The home directory of docker_user, and where configuration files will live |

## Below are the instructions for updating containers:

### Via Docker Run/Create
* Update the image: `docker pull wiorca/docker-windscribe`
* Stop the running container: `docker stop docker-windscribe`
* Delete the container: `docker rm docker-windscribe`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start docker-windscribe`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull docker-windscribe`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d docker-windscribe`
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (especially useful if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one run:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once docker-windscribe
  ```
* You can also remove the old dangling images: `docker image prune`

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:
```
git clone https://github.com/wiorca/docker-windscribe.git
cd docker-windscribe
docker build \
  --no-cache \
  --pull \
  -t wiorca/docker-windscribe:latest .
```
