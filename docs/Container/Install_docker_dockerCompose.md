# Docker and Docker Compose

## 1.Introduction 

### Docker Editions
There are two editions of Docker available.

- Community Edition (CE): ideal for individual developers and small teams looking to get started with Docker and 
  experimenting with container-based apps.
- Enterprise Edition (EE): Designed for enterprise development and IT teams who build, ship, and run business-critical 
  applications in production at scale.

> This guide will cover installation of Docker CE on Debian Linux. But let’s first look at common docker terminologies.


### Docker Components / Terminologies
Below are commonly used terminologies in Docker ecosystem.

- **Docker daemon**: This is also called Docker Engine, it is a background process which runs on the host system responsible for building and running of containers.
- **Docker Client**: This is a command line tool used by the user to interact with the Docker daemon.
- **Docker Image**: An image is an immutable file that’s essentially a snapshot of a container. A docker image has a file system and application dependencies required for running applications.
- **Docker container**: This is a running instance of a docker image with an application and its dependencies. Each container has a unique process ID and isolated from other containers. The only thing containers share is the Kernel.
- **Docker registry**: This is an application responsible for managing storage and delivery of Docker container images. It can be private or public.

## 2. Install Docker CE on Debian 12/11/10


1) Install Dependency packages
Start the installation by ensuring that all the packages used by docker as dependencies are installed.

```shell
sudo apt update
sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common

```
2) Add Docker’s official GPG key
Import Docker GPG key used for signing Docker packages.
```shell
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
```
3) Add the Docker repository
Add Docker repository which contain the latest stable releases of Docker CE.
```shell
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

```
This command will add the line shown in `/etc/apt/sources.list` file.

4) Install Docker and Docker Compose

```shell
#Update the apt package index.
sudo apt update

# To install Docker CE on Debian, run the command:
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


# Start and enable docker service:
sudo systemctl enable --now docker
```


This installation will add docker group to the system without any users. Add your user account to the group to run 
docker commands as non-privileged user.
```shell
# add docker group to current user
sudo usermod -aG docker $USER

# you need to re-login to get the updated group 
```

## 3. Test the docker and docker compose

Check docker and compose version.

```shell
docker version

docker compose version

```

### 3.1 Run a test docker container

```shell
docker run --rm -it  --name test alpine:latest /bin/sh

# this will open a shell in the container, you can get the os info with below command
cat /etc/os-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.16.0
PRETTY_NAME="Alpine Linux v3.16"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://gitlab.alpinelinux.org/alpine/aports/-/issues"

# exit the shell
```

### 3.2 Test Docker Compose
```shell
# Create a test Docker Compose file.
vim docker-compose.yml

# Add below data to the file.
version: '3'  
services:
  web:
    image: nginx:latest
    ports:
     - "8080:80"
    links:
     - php
  php:
    image: php:7-fpm

# Start service containers. the current working directory must contain the compose config file
sudo docker compose up -d

# show running containers
sudo docker compose ps

# Destroy containers
docker compose stop
docker compose rm

# output
Going to remove vagrant_web_1, vagrant_php_1
Are you sure? [yN] y
Removing vagrant_web_1 … done
Removing vagrant_php_1 … done
```


## 4. Docker supervision(UI)

https://computingforgeeks.com/install-docker-ui-manager-portainer/