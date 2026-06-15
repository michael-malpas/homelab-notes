# Day 9 - Docker Compose and Multi-Container Applications

## Goals

- Understand Docker Compose
- Create compose files
- Start multi-container applications
- Manage services
- Use persistent volumes
- Configure networks
- Use environment variables
- Troubleshoot container stacks

## Build Plan

- Docker compose stack
```
nginx
|
|
apache

shared docker network
```
small monitoring stack planned for later

## Verify Docker
check services:
```bash
systemctl status docker
```

Check containers:
```bash
docker ps
```

## Install Docker Compose
```bash
docker compose version
```
Expects:
docker compose v2.x.x

Not installed:
```bash
sudo apt install docker-compose -y
```

Verify:
```bash
docker compose version
```

Results:
```Docker Compose version 2.40.3+ds1-0ubuntu1
```

## Create Compose Project Structure
Create Workspace
```bash
mkdir -p ~/docker-compose-lab
cd ~/docker-compose-lab
```

Create:
```bash
touch compose.yaml
```
verify:
```bash
ls
```

## First Compse File
Edit
```bash
nano compose.yaml
```

Add:
```
services:

  nginx:
    image: nginx
    container_name: nginx-compose
    ports:
      - "8080:80"
```

## Start The Stack

Run:
```bash
docker compose up -d
```
-d so it's detached and you can continue to work

Expected: creating nginx-compose

Verify:
```bash
docker ps
```

Browse:
```
http://SERVER_IP:8080
```

Expected:
nginx start page

Confirmed

## Inspect Compose Resource
View:
```bash
docker compose ps
```

Inspect:
```bash
docker compose config
```
Fully Rendered Configuration ^

## Stop the Stack
Stop:
```bash
docker compose down
```

Verify:
```bash
docker ps
```

## Add Second Service

Edit:
```bash
nano compose.yaml
```

Replace with:
```
services:

  nginx:
    image: nginx
    container_name: nginx-compose
    ports:
      - "8080:80"

  apache:
    image: httpd
    container_name: apache-compose
    ports:
      - "8081:80"
```

Start:
```bash
docker compose up -d
```

Verify:
```
docker ps
```

Expected:
```
nginx-compose
apache-compose
```

Test:
```
http://SERVER_IP:8080
http://SERVER_IP:8081
```

Confirmed both are working

## Docker Networks
View networks:
```bash
docker network ls
```

Inspect:
```bash
docker network inspect docker-compose-lab_default
```
Automatic Networking - containers can talk to each other

## Test Container Communication
Enter nginx:
```bash
docker exec -it nginx-compose bash
```

Install ping:
```bash
apt install iputils-ping -y
```

Test:
```bash
ping apache
```

Received replies as expected. Able to ping by service/host name. Could also ping by ip address.


## Environment Variables
Create:
```bash
nano .env
```

Add:
```
WEB_PORT=8080
```

Update compose file:
```
services:

  nginx:
    image: nginx
    ports:
      - "${WEB_PORT}:80"
```

Restart:
```bash
docker compose down
docker compose up -d
```

Verify
```bash
docker compose config
```
Resolved the ports for nginx automatically based on the port defined in the env file. Allows for changes to variables across multiple files


## Persistent Volumes
Create:
```bash
mkdir html
```

Create Page:
```bash
nano html/index.html
<h1>Docker Compose Lab</h1>
<p>Day 9 Working</p>
```

Update nginx service:
```
services:

  nginx:
    image: nginx
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

Restart:
```bash
docker compose down
docker compose up
```

Browse again - Custom page appears

## Sysadmin Exercise
Modify:
```bash
nano html/index.html
```

Updated text.

Refreshed browser.

No restart required, page updates with changes.

## Logs

View all logs:
```bash
docker compose logs
```

Specific Service Logs:
```bash
docker compose logs nginx
```

Live:
```bash
docker compose logs -f nginx
```

## Resource Management
Stop one service:
```bash
docker compose stop apache
```

Verify
```bash
docker ps
```

Only Nginx is still running.

Start:
```bash
docker compose start apache
```

Verify:
```bash
docker ps
```

Apache is running again with the network

## Scale a service
Edit Compose File:
```
services:

  nginx:
    image: nginx
```

Start Multiple Instances:
```bash
docker compose up -d --scale nginx=3
```

Observe:
```bash
docker ps
```

Created multiple nginx containers automatically and networked them.

These concepts will be used/expanded on later with scaling practice.

## Create Monitoring Container
Update compose.yaml:
```
services:

  nginx:
    image: nginx
    ports:
      - "8080:80"

  uptime:
    image: louislam/uptime-kuma
    ports:
      - "3001:3001"
```

Start:
```bash
docker compose up -d
```

Browser:
```
http://SERVER_IP:3001
```

Full Uptime Kuma application running with Compose

## Compose Troubleshooting tips
Check Status:
```bash
docker compose ps
```

View logs:
```bash
docker compose logs
```

Validate Syntax
```bash
docker compose config
```

^ Very commonly used for troubleshooting docker compose issues, learn 'em, love 'em.

## DevOps Challenge
Create a reuseable stack
```
compose-lab/
├── compose.yaml
├── .env
├── html/
│   └── index.html
└── README.md
```

Requirements:
- nginx service
- custom webpage
- environment variables
- volume mount
- documented setup 
- anyone shoudl be able to clone the repo and run "docker compose up -d" to deploy app

## Stretch Goal

Compose + Ansible:

Create an ansible playbook that:
1. Installs Docker
2. Create project directory
3. copies compose.yaml
4. runs
```bash
docker compose up-d
```


Created playbook ~/homelab-notes/ansible/playbooks/docker_compose.yml
```YAML
---
- name: Docker Compose Setup
  hosts: all
  become: true

  tasks:

    - name: Install Docker Prerequisite packages
      apt:
        name:
          - ca-certificates
          - curl
        state: present
        update_cache: true

    - name: Install Docker
      apt:
        name: docker.io
        state: present

    - name: Install Docker-Compose
      apt:
        name: docker-compose
        state: present

    - name: Ensure Docker Started
      service:
        name: docker
        state: started
        enabled: yes

    - name: Copy compose files
      copy:
        src: /home/michael/homelab-notes/week2/day9/compose-lab/.
        dest: /home/michael/

    - name: Run Docker Compose up -d
      community.docker.docker_compose_v2:
        project_src: /home/michael/compose-lab/
        state: present
```

## End-of-day Success Checklist
- Install Compose
- Create compose.yaml
- Launch Services
- Use networks
- Use volumes
- Use environment variables
- Read logs
- Troubleshoot containers
- Deploy Uptime Kuma
- Push documentation to GitHub
