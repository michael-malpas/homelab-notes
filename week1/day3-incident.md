# Nginx Failure Simulation

## Problem

Nginx service failed to start.

## Symptoms

systemctl status nginx showed startup failure

## Investigation

Check:

systemctl status nginx

journalctl -u nginx

nginx -t

## Root Cause

Configuration syntax error in nginx.conf

## Resolution

Restored backup configuration.

Restarted service.

## Validation

nginx -t successful

systemctl status nginx active
