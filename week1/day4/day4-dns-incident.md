# DNS Failure Simulation

## Problem

Dns name resolution fails

## Symptoms

ping google.com fail
ping 8.8.8.8 success

## Investigation

review /etc/resolv.conf

## Root Cause

/etc/resolv.conf contains an invalid nameserver "1.1.1.999"

## Resolution

Restore backup of resolv.conf from ~/etc/resolv.conf.bak to /etc/resolv.conf

## Validation

ping google.com success
ping 8.8.8.8 success
