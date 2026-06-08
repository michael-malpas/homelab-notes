# Day 4: Networking, DNS, Firewalls, and Connectivity Troubleshooting

## Plan
- DNS problems
- Firewall rules
- Port issues
- Routing issues
- Service binding issues

"Is the application broken, or is this a network issue?"

## Goals
- Understand IP addressing
- Understand ports
- Understand DNS
- Test connectivity
- Troubleshoot networking issues
- Configure firewalls
- Understand how services communicate

## Build plan
Windows PC
     |
     |
     v
Ubuntu Server
     |
     +-- Port 22 (SSH)
     |
     +-- Port 80 (Nginx)

## Inspecting Network Interfaces
Finding IP:
```bash
ip addr
```

Interface States:
```bash
ip link
```

## Understanding Routing

Commands:
```bash
ip route
```

Purpose:
Shows how traffic leaves the server


## Testing Connectivity
Ping Gateway:
```bash
ping -c 4 GATEWAY ADDRESS
```

Ping google DNS:
```bash
ping -c 4 8.8.8.8
```

Purpose:
Gateway confirms network connectivity internal, google dns confirms external network connectivity (internet connection)

## Test DNS

Check DNS resolution:
```bash
nslookup google.com
```

DIG:
```bash
dig google.com
```

## Understanding the difference
commands:
```bash
ping -c 4 8.8.8.8
ping -c 4 google.com
```

If pinging by hostname fails, there is a dns resolution issue (same as I've been working with windows for years)

## View Listening Ports
Check Services:
```bash
ss -tulpn
```

Look for:
22
80

Expected:
sshd
nginx

common ports:
22   SSH
80   HTTP
443  HTTPS
53   DNS
3306 MySQL
5432 PostgreSQL


## Test Open Ports

install netcat:
```bash
sudo apt install netcat-obenbsd
```

Test SSH:
```bash
nc -zv localhost 22
```

Test Nginx:
```bash
nc -zv localhost 80
```

Expected:
success

## Install and configure UFW Firewall
Ubuntu Firewall:
UFW

Check Status:
```bash
sudo ufw status
```

Allow ssh:
```bash
sudo ufw allow ssh
```

Allow http:
```bash
sudo ufw allow 80/tcp
```

Enable Firewall:
```bash
sudo ufw enable
```

Verify
```bash
sudo ufw status verbose
```

## Break the web server
Block http:
```bash
sudo ufw deny 80/tcp
```

Verify:
```bash
sudo ufw status numbered
```

From windows browser:
htttp://SERVER_IP

Expected:
Failed to connect

## Troubleshoot

Check Service
```bash
systemctl status nginx
```

Result:
running

Check Listening Ports:
```bash
ss -tulpn | grep 80
```

Result:
nginx listening

Check firewall
```bash
sudo ufw status
```

Result:
80/tcp DENY

Root Cause Found

## Fix Problem

Remove deny rule:
```bash 
sudo ufw status numbered
```

Identify rule for DENY ex:
[1] 80/tcp DENY

Delete:
```bash
sudo ufw delete 1
```

Allow:
```bash
sudo ufw allow 80/tcp
```

Verify access restored:
Test in windows browser

Expected:
Successful

## Create Incident Report
see day4-firewall-incident.md

## DNS Failure Simulation

Backup:
```bash
sudo cp /etc/resolv.conf ~/resolv.conf.bak
```

View:
ccat /etc/resolv.conf

Temporarily break DNS:
```bash
sudo nano /etc/resolv.conf
```

Replace nameserver with
1.1.1.999
Save

Test:
```bash
ping google.com
```

Fails

Test:
```bash
ping 8.8.8.8
```

Works

Diagnosis:
DNS Broken
Network Fine

Restore:
```bash
sudo cp ~/resolv.conf.bak /etc/resolv.conf
```

Test again

Works


## Troubleshooting Flowchart

cannot reach application

1. Is service running?

systemctl status

2. Is port listening?

ss -tulpn

3. Is firwall blocking?

ufw status

4. Is DNS working?

nslookup

5. Can host be pinged?

ping

6. Can port be reached?

nc


## Incident Reporting

Created incident report for DNS Simulation
See day4-dns-incident.md

## Trace Network Path
Install:
```bash
sudo apt install traceroute
```

Run:
```bash
traceroute google.com
```

See Open Sockets:
```bash
lsof -i
```

Watch Network Connections Live:
```bash
watch ss -tulpn
```

Test HTTP From server:
```bash
curl localhost
```

### End of Day Checklist
- use ip addr
- use ip route
- understand gateways
- understand dns
- use dig
- use nslookup
- use ss
- use nc
- configure UFW
- troubleshoot connectivity
- identify dns failures
- document incidents
- push notes to GitHub

