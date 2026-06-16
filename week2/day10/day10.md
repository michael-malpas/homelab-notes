# Monitoring, Logging and Observability

## Goals
- Understand monitoring concepts
- Deploy Grafana
- Deploy Prometheus
- Collect Metrics
- Monitor Docker
- Create Dashboards
- Create health checks
- Create monitoring documentation

## Build Plan
```
Ubuntu Server
     |
Docker
     |
+------------+
| Prometheus |
+------------+
     |
+------------+
|  Grafana   |
+------------+
     |
Dashboard
```

## Monitoring Concepts

### Metrics
Numerical data over time
```
CPU Usage
Memory Usage
Disk Usage
Network Traffic
```

Example:
```
CPU = 12%
RAM = 43%
```

### Logs
Text record of events
```
Nginx started
User logged in
Container crashed
```

Example:
```
2026-06-16 nginx started
```

### Monitoring
Collecting Inforamtion

Example:
```
Server CPU
Disk Usage
Memory Usage
```

### Observability
Understand WHY something happened.

Example:
```
CPU is 95%

Why?

Prometheus shows spike
Grafana dashboard shows nginx traffic
Logs show 5000 requests
```


## Monitoring Project
Create Directory:
```bash
mkdir -p ~/monitoring
cd ~/monitoring
```

Create:
```bash
mkdir prometheus
```

## Create Prometheus Config
Create:
```bash
nano prometheus/prometheus.yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus

    static_configs:
      - targets:
          - localhost:9090
```

Save

## Create Compose File

Create:
```bash
nano compose.yaml
services:

  prometheus:
    image: prom/prometheus
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3000:3000"
```

## Start Stack
Run:
```bash
docker compose up -d
```

Verify:
```bash
docker ps
```

Expected:
```
promethus
grafana
```

## Explore Promethus
Open
```
http://SERVER_IP:9090
```

Test Query:
```
up
```

Execute.

Expected:
```
1
```

Meaning:
```
Target Healthy
```

## Explore Grafana
Open:
```
http://SERVER_IP:3000
```

Login
```
admin
admin
```

Grafana will force password change

Set a new password.


## Connect Grafana to Prometheus
Inside Grafana
```
Connections
Data Sources
Add data Source
Prometheus
```

URL:
```
http://prometheus:9090
```

Click:
```
Save & Test
```

Expected
```
Data Source is working
```

## Create Dashboard
Create:
```
Dashboards
New Dashboard
Add Visualization
```

Select Prometheus


Query:
```
up
```

Run

Save dashboard:
```
Lab Dashboard
```

## Monitor Docker Containers

Run:
```bash
docker stats
```

Observe:
```
CPU
RAM
Network
Block I/O
```

This is real-time monitoring

## Sysadmin exercise

Create:
```bash
mkdir -p ~/scripts
```

Create:
```bash
nano ~/scripts/system_health.sh
#!/bin/bash

echo "===== SYSTEM HEALTH ====="

echo
echo "DATE:"
date

echo
echo "UPTIME:"
uptime

echo
echo "DISK:"
df -h /

echo
echo "MEMORY:"
free -h

echo
echo "DOCKER:"
docker ps
```

Make Executable:
```bash
chmod +x ~/scripts/system_health.sh
```

Run:
```bash
~/scripts/system_health.sh
```


## Logging Output
Create:
```bash
mkdir -p ~/logs
```

Run:
```bash
~/scripts/system_health.sh >> ~/logs/system_health.log
```

Check:
```bash
cat ~/logs/system_health.log
```

## Create Health Checks

Create:
```bash
nano ~/scripts/docker_health.sh
#!/bin/bash

echo "===== DOCKER HEALTH ====="

systemctl is-active docker

docker ps

curl -I localhost:3000

curl -I localhost:9090
```

Make executable:
```bash
chmod +x ~/scripts/docker_health.sh
```

Run:
```bash
~/scripts/docker_health.sh
```


## Add Timestamps
Update:
```bash
nano ~/scripts/docker_health.sh
```
Add:
```
echo "$(date)"
```


## Schedule Monitoring
Edit cron:
```bash
crontab -e
```

Add:
```cron
*/15 * * * * /home/michael/scripts/docker_health.sh >> /home/michael/logs/docker_health.log
```

Meaning:
```
every 15 minutes
```

Verify:
```bash
crontab -l
```

## Enterprise Exercise
Create a report script:
```bash
nano ~/scripts/server_report.sh
```

Requirements:

Collect - 
```
Hostname
IP Address
Disk Usage
Memory Usage
Docker Containers
Running Services
```

Save output to 
```
~/logs/server_report.log
```

## Troubleshooting Practice
Stop Grafana
```bash
docker stop grafana
```

Verify:
```bash
docker ps
```

Run:
```bash
~/scripts/docker_health.sh
```

Observe failure

Start Again:
```bash
docker start grafana
```

Verify Health Restored

## Stretch Goals

Add nginx container from day 9 monitoring

Track:
- Availability
- Response Times
- Errors

Created new folder under day10/monitoring_exercise.

Created new compose.yaml file
```
services:
  nginx:
    image: nginx:latest
    ports:
      - 8080:8080
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro

  prometheus:
    image: prom/prometheus
    ports:
      - 9090:9090
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - 3000:3000
    depends_on:
      - prometheus
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
      - grafana-data:/var/lib/grafana

  nginx-exporter:
    image: nginx/nginx-prometheus-exporter
    command:
    - --nginx.scrape-uri=http://nginx/nginx_status
    ports:
      - 9113:9113
    depends_on:
      - nginx

  blackbox-exporter:
    image: prom/blackbox-exporter
    ports:
      - 9115:9115

  loki:
    image: grafana/loki:latest
    ports:
      - 3100:3100

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - /var/lib/docker/containers:/var/lib/docker/containers
      - ./promtail-config.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml

volumes:
  grafana-data:
```

Creating:
- nginx
- prometheus
- grafana
- nginx-exporter
- blackbox-exporter
- loki
- promtail

Troubleshooting grafana configuration to save settings between restarts (see changes/mounting volume)


Created Dashboards to test how it's able to track various functions in grafana using information

gathered from prometheus/loki/blackbox-exporter/promtail

with specific queries in grafana able to create dashboards for monitoring and alerting for pretty much any criteria.

How is data being collected > how is grafana receiving it > how does grafana interpret the data it's receiving.
