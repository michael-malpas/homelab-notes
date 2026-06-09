# System Health Failure Simulation

## Problem
System health script report shows nginx is not active

## Symptoms
Nginx is not running

## Investigation

systemctl status nginx shows service stopped

## Root Cause

Nginx service manually disabled

## Resolution

systemctl start nginx

## Validation

system ctl status nginx

~/scripts/system_health.sh

Verified nginx shows active/running again
