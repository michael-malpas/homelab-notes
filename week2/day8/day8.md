# Docker Fundamentals and Containers

## Goals

- Understand what containers are
- Install Docker
- Run containers
- Pull images
- Inspect containers
- Mount volumes
- Publish ports
- Read logs
- Troubleshoot containers

## Build Plan
- Docker Host
	- nginx container
	- alpine container
	- ubuntu container

Will deploy a custom web page from linux filesystem into a container

## Understand containers

Think:

Traditional server:
```
application
application
application
linux
```

Problems:
- dependency conflicts
- different versions
- difficult deployments


Containers:
```
container
container
container
	|
Docker Engine
	|
Linux
```

Each application gets its own environment

## Install Docker
Update:
```bash
sudo apt update
```

Install Prereqs:
```bash
sudo apt install \
	ca-certificates \
	curl \
	gnupg \
	lsb-release -y
```

Install Docker:
```bash
sudo apt install docker.io -y
```

Verify:
```bash
docker --version
```

Check Services:
```bash
systemctl status docker
```

Expected:
```
active (running)
```

## Add Account to Docker Group
Add user:
```bash
sudo usermod -aG docker michael
```

Verify:
```bash
groups
```

docker group doesn't appear. Log out and ssh back in.

Reverify:
```bash
groups
```

docker now appears

Test:
```bash
docker ps
```

## First Container
run:
```bash
docker run hello-world
```

Docker Automatically:
1. Pulls image
2. Creates container
3. Runs it
4. exits

Expected:
```
Hello from Docker!
```


## Inspect Images

View downloaded images
```bash
docker images
```

Lists all downloaded images (currently hello-world latest)

Image = blueprint

Container = running instance

## Run Alpine Linux
Pull:
```bash
docker pull alpine
```

Run:
```bash
docker run alpine echo "Hello from Alpine"
```

Launch shell
```bash
docker run -it alpine sh
```

Inside:
```bash
cat /etc/os-release
```

Notice - Alpine

Exit
```bash
exit
```

## Run Ubuntu Container
Pull
```bash
docker pull ubuntu
```

Run:
```bash
docker run -it ubuntu bash
```

Inside:
```bash
ls /
```

Check:
```bash
cat /etc/os-release
```
Notice - Ubuntu 26.04


Exit:
```bash
exit
```

## Run Nginx Container
Start:
```bash
docker run -d \
-- name nginx-test \
-p 8080:80 \
nginx
```
- -d detached
- --name container name
- -p port mapping
- nginx app

Verify:
```bash
docker ps
```

Expected:
```
nginx-test
```

Visit: (windows web browser)
```
http://SERVER_IP:8080
```

Expected:
```
Welcome to nginx!
```

## Container Management
Stop:
```bash
docker stop nginx-test
```

Start:
```bash
docker start nginx-test
```

Restart:
```bash
docker restart nginx-test
```

Delete
```bash
docker rm -f nginx-test
```

## Inspect Containers
Run nginx again:
```bash
docker run -d \
--name nginx-test \
-p 8080:80 \
nginx
```

Inspect:
```bash
docker inspect nginx-test
```

Huge Output. Notice Key features:
- IPAddress
- Mounts
- Ports

Can | grep output from docker inspect nginx-test if needed

## Container Logs
View:
```bash
docker logs nginx-test
```

Live Logs:
```bash
docker logs -f nginx.test
```

Openinging browser and can watch logs update with requests for webpage

Exit:
```bash
CTRL+C
```

## Enter a Running Container
Execute shell:
```bash
docker exec -it nginx-test bash
```

Inside:
```bash
ls /usr/share/nginx/html
```

View:
```bash
cat /usr/sahre/nginx/html/index.html
```

Exit:
```bash
exit
```

## Create Custom Website
Create Directory:
```bash
mkdir -p ~/docker-site
```

Create Page:
```bash
nano ~/docker-site/index.html
<h1>Michael's DevOps Lab</h1>
<p>Docker is working!</p>
```

## Mount a Volume
Delete old container:
```bash
docker rm -f nginx-test
```

Run:
```bash
docker run -d\
--name nginx-test \
-p 8080:80 \
-v ~/docker-site:/user/share/nginx/html \
nginx
```

Browse:
```
http://SERVER_IP:8080
```

Expected:
```
Michael's Devops Lab
```

## Sysadmin Exercise
Update page:
```bash
nano ~/docker-site/index.html
```
Change text

Refresh Browser

Observe:
```
No container restart required
```

The volume is live

## Resrouce Monitoring

View Containers:
```bash
docker ps
```

View Resources:
```bash
docker stats
```
- CPU
- Memory
- Network

Exit:
```bash
CTRL+C
```

## Cleanup

View all containers:
```bash
docker ps -a
```

Remove stopped containers:
```bash
docker container prune
```

View Images:
```bash
docker images
```

Remove unused:
```bash
docker image prune
```

Note: docker image prune will only remove "dangling" images, to remove all unused images you'll have to use:
```bash
docker image prune -a
```

# Stretch Goals

## Run Multiple Containers
```bash
docker run -d --name web1 -p 8081:80 nginx
docker run -d --name web2 -p 8082:80 nginx
```

Verify both

## Environment Variables
Run:
```bash
docker run -e MYVAR=test alpine env
```

Observe: 
```
MYVAR=test
```

## Persistent Storage
Create:
```bash
docker volume create nginx-date
```

Inspect:
```bash
docker volume ls
```

## DevOps Challenge
Create a script:
```bash
~/scripts/docker_health.sh
```

Requirements:
- Verify Docker Service Running
- Verify nginx Container running
- Verify port 8080 responding
- Write results to log file

Created script:
```bash
nano ~/scripts/docker_health.sh
#!/bin/bash

LOGFILE="$HOME/docker_health.log"

exec >> "$LOGFILE" 2>&1
echo ==========================================
date "+%Y-%m-%d %H:%M"
echo

if
	systemctl --quiet is-active docker
then
	echo Docker: Running
else
	echo Docker: NOT Running
fi

CONTAINER="nginx-test"

if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" = "true" ]; then
	echo Container: Running
else
	echo Container: NOT Running
fi

if curl -s -o /dev/null http://localhost:8080; then
	echo HTTP: OK
else
	echo HTTP: NOT OK
fi
echo ==========================================
echo
```
Tested variable conditions, container started/stopped, docker disabled etc. 

docker_health.log tracks conditions correctly.

## End-of-day Success Checklist
- Install Docker
- Understand images vs containers
- Pull images
- Run containers
- Stop/start containers
- Use docker exec
- Use docker logs
- Use docker inspect
- Publish ports
- Mount volumes
- Monitor resources
- Push notes to GitHub
