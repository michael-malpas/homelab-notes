# Nginx Failure Simulation

## Problem
Nginx server not reachable from windows web browser

## Symptoms
When trying to access at SERVER ADDRESS returns unable to connect

## Investigation
Check Service:
systemctl status nginx

Result:
running

Check listening ports:
ss-tulpn | grep 80

Result:
nginx listening

Check firewall
sudo ufw status

Result:
80/tcp DENY
ipv6 80/tcp DENY

## Root Cause

UFW Firewall misconfigured to deny connections on port 80/tcp

## Resolution

Deleted DENY rules for 80/tcp

Created ALLOW rules for 80/tcp

## Validation

sudo ufw status

validated firewall configuration

attempted to connect to webpage on SERVER ADDRESS

successfully connected
