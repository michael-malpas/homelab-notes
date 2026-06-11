# Ansible Become Troubleshooting

## Issue

Ansible playbooks using:

become: true

failed with:

sudo: interactive authentication is required

or

Timed out waiting for become success

## Environment

Ubuntu 26.04
Python 3.14.4
Ansible Core 2.20.1

## Investigation

Verified:
- sudo worked manually
- sudo permissions were correct
- inventory was correct
- local connection worked

Failure occurred only during privilege escalation.

## Resolution

Configured passwordless sudo:

sudo visudo

Added:

michael ALL=(ALL:ALL) NOPASSWD: ALL

## Validation

ansible-playbook executed successfully.
