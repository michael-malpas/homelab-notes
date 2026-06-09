# Day 5 Notes

## Goals

- write a bash script
- use variables 
- use loops
- use conditionals 
- parse logs
- schedule jobs with cron
- automate system checks
- build operational scripts

## Build toolkit

Scripts:
- disk_check.sh
- user_report.sh
- nginx_health.sh
- backup_notes.sh
- log_monitor.sh

## Create Scripts Directory
Create:
```bash
mkdir -p ~/scripts
```

Verify:
```bash
tree ~
```

Expected: 
scripts/

## Create Test Script
```bash
nano ~/scripts/hello.sh
```

Create Script
```bash
#!/bin/bash

echo "Hello Michael"
echo " Welcome to your DevOps lab"
```

Make Executable:
```bash
chmod +x ~/scripts/hello.sh
```

Run:
```bash
~/scripts/hello.sh
```


## Learn Variables

Create:
```bash
nano ~/scripts/variable.sh

#!/bin/bash

NAME="Michael"

echo "Hello $NAME"
```

Make exec/run:
```bash
chmod +x ~/scripts/variables.sh
~/scripts/variables.sh
```

## System Variables Example

Create:
```bash
nano ~/scripts/system_info.sh
#!/bin/bash

echo "User:$USER"
echo "Home:$HOME"
echo "Shell:$SHELL"
echo "Hostname:$(hostname)"
```

Run:
```bash
chmod +x ~/scripts/system_info.sh
~/scripts/system_info.sh
```

## Disk Usage Check

~/scripts/disk_check.sh
```bash
#!/bin/bash

df -h /
```

```bash
chmod +x ~/scripts/disk_check.sh
~/scripts/disk_check.sh
```

Improve:
```bash
#!/bin/bash

USAGE=$(df / | awk 'NR==2 {print $5}')

echo "Root filesystem usage: $USAGE"
```
awk to parse the text, NR== means consider line X (in this case 2). {print $5} = print field 5


## Conditionals
Create:
```bash
nano ~/scripts/nginx_check.sh
#!/bin/bash

if systemctl is-active --quiet nginx
then
	echo "Nginx is running"
else
	echo "Nginx is NOT running"
fi
chmod +x ~/scripts/nginx_check.sh
~/scripts/nginx_check.sh
```


## Test Failure Detection
Stop nginx:
```bash
sudo systemctl stop nginx
```

Run Script:
```bash
~/scripts/nginx_check.sh
```

Expected:
Nginx is NOT running

Restart:
```bash
sudo systemctl start nginx
```

Retry script, expected:
Nginx is running

## User Report Script
```bash
nano ~/scripts/user_report.sh
#!/bin/bash

echo "Users with Bash Shell"

grep "bin/bash" /etc/passwd
```

Test returns a list of users with an interactive bash shell.

Improving:
```bash
nano ~/scripts/user_report.sh
#!/bin/bash

COUNT=$(grep -c "bin/bash" /etc/passwd)

echo "Total interactive users: $COUNT"
```
prints how many users have interactive sessions

## Loops
Create:
```bash
nano ~/scripts/countdown.sh
#!/bin/bash

for i in{1..5}
do
	echo $i
done
```

Experimenting with alternative values
```bash
for i in {1..10}
for i in {1..30}
```

## Log Parsing

Create:
```bash
nano ~/scripts/failed_logins.sh
#!/bin/bash

journalctl -u ssh | grep Failed
```

Run:
```bash
chmod +x ~/scripts/failed_logins.sh
~scripts/failed_logins.sh
```

Shows just failed ssh login attempts

## Advanced Nginx Health Check

Create:
```bash
nano ~/scripts/nginx_health.sh
#!/bin/bash

if curl -s https://localhost > /dev/null
then
	echo "Website responding"
else
	echo "Website unavailable"
fi
```

## Backup Script
Create:
```bash
nano ~/scripts/backup_notes.sh
#!/bin/bash

DATE=$(date +%Y-%m-%d)

tar -czf "HOME/notes-$DATE.tar.gz" "$HOME/homelab-notes"
```

Verifying:
```bash
ls *.tar.gz
```
While in ~ directory

## Cron
Cron schedules tasks. Like Windows Task Scheduler

Edit cron jobs:
```bash
crontab -e
```
Add:
```bash
0 8 * * * /home/michael/scripts/backup_notes.sh
```
Meaning:
- minute = 0
- hour = 8
- Every day
View:
```bash
crontab -l
```

## Schedule a Test Job
```bash
crontab -e
*/2 * * * * echo "Cron Works" >> /home/michael/cront-test.log
```
Understanding cron notation:
- minute
- hour
- day of month
- month of year
- day of week
- */ means at every interval
- ex: 2 * * * * means at minute 2 of every hour of every day
- ex2: */2 * * * * means every 2 minutes.


## System Health Report

Create:
```bash
nano ~/scripts/system_health.sh
#!/bin/bash

echo "===== SYSTEM HEALTH ====="

echo
echo "HOSTNAME:"
hostname

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
echo "NGINX:"
systemctl is-active nginx
```

## Incident Simulation
see day5-incident.md

## Learned
- Variables
- Conditionals
- Loops
- Functions

## Scripts created
- hello.sh
- disk_check.sh
- nginx_check.sh
- user_report.sh
- back_notes.sh
- system_health.sh


## Stretch Goal

Create a script that checks:
- ssh
- nginx
- cron
service status

```bash
nano ~/scripts/service_status.sh
#!/bin/bash

SERVICES=("ssh" "nginx" "cron")

for service in "${SERVICES[@]}"; do
	status=$(systemctl is-active "$service")

	if systemctl is-active --quiet $service
	then
		echo "[OK]	$service is running"
	else
		echo "[FAIL]	$service is NOT running (status: $status)"
	fi
done
```

## DevOps Challenge
build: health_dashboard.sh
requirements:
- Check Disk usage
- Check Memory
- Check nginx
- Check ssh
- Check uptime
- Write results to a log file

```bash
#!/bin/bash

LOGFILE="$HOME/health_dashboard.log"
SERVICES=("nginx" "ssh")

exec >> "$LOGFILE" 2>&1

echo "===== Health Report ====="
echo

date +%Y-%m-%d
for service in "${SERVICES[@]}"; do
	if systemctl is-active --quiet $service
	then
		echo "$service: Running"
	else
		echo "$service: Not Running"
	fi
done
echo "Disk: $(df / | awk 'NR==2 {print $5}')"
echo "Memory:"$(free | awk 'NR==2 {printf("%.2f%%\n", $3/$2 * 100)}')
echo
```

- LOGFILE to move all output to a .log file instead of the console
- use loop to check services and print output of service status
- using df with awk to print disk usage %
- using free with awk to print out a % usage of memory
- printf uses formating % starts the formating, .2 says 2 decimals, %% escapes the formating to actual print a %
- $3/$2 is diving used kb by total kb * 100 to make HR decimal
