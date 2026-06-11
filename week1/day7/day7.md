# Ansible Fundamentals and First Infrastructure as Code

## Goals

- Understand Ansible architecture
- Create an inventory
- Run ad-hoc commands
- Create playbooks
- Automate package installation
- Automate service management
- Automate file deployment
- Understand idempotency

## Build Plan
- Ansible
-- Inventory.ini
-- Playbooks/
--- isntall_nginx.yml
--- users.yml
--- system_update.yml
-- templates/

## Understand Ansible

Think:

Traditional Admin

- Server 1
- Server 2
- Server 3

Login to each manually

VS:

Ansible:

- Control Node
-- Server 1
-- Server 2
-- Server 3

One command controls many systems.

## Install Ansible

Update packages:
```bash
sudo apt update
```

Install:
```bash
sudo apt install ansible -y
```

Verify:
```bash
ansible --version
```

Version: 

Ansible Core 2.20.1

## Create Repository Structure
Inside homelab-notes
```bash
mkdir -p ansible/playbooks
mkdir -p ansible/templates
```

Verify:
```bash
tree ansible
```

## Create Inventory
```bash
nano ansible/inventory.ini
[webservers]
localhost ansible_connection=local
```
Managing local machine.

Later will focus on how to configure for multiple VMs

## Test Connectivity
Run:
```bash
ansible all -i ansible/inventory.ini -m ping
```

Expected:
```bash
localhost | SUCCESS => {
	"changed": false,
	"ping": "pong"
}
```

## Run Ad-hoc Commands
Get Uptime:
```bash
ansible all -i ansible/inventory.ini -m command "uptime"
```

Get Hostname:
```bash
ansible all -i ansible/inventory.ini -m command "hostname"
```

Check Disk
```bash
ansible all -i ansible/inventory.ini -m command "df -h /"
```

## Gather Facts
Run:
```bash
ansible all -i ansible/inventory.ini -m setup
```

Lots of output.

This is system information Ansible collects

Filter It:
```bash
ansible all -i ansible/inventory.ini -m setup -a "filter=ansible_hostname"
ansible all -i ansible/inventory.ini -m setup -a "fitler=ansible_distribution"
ansible all -i ansible/inventory.ini -m setup -a "filter=ansible_default_ipv4"
ansible all -i ansible/inventory.ini -m setup -a "filter=ansible_memtotal_mb"
```

## Create First Playbook
Create:
```bash
nano ansible/playbooks/system_update.yml
---
- name: Update System
  hosts: all
  become: true

  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
```

Run:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/system_update.yml
```

## Troubleshooting Ansible playbook
see ~/homelab-notes/docs/day7-ansible-become-incident.md

## Learn Idempotency
notice:

```bash
ok
```

Instead of:

```bash
changed
```

Running the same playbook repeatedly shouldn't break anything

## Install Nginx with Ansible
Create:
```bash
nano ansible/playbooks/install_nginx.yml
---
- name: Install Nginx
  hosts: all
  become: true

  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
```

Run:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/install_nginx.yml

PLAY [Install Nginx] ***************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]

TASK [Install Nginx] ***************************************************************************************************
ok: [localhost]

PLAY RECAP *************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Manage Services

Expand playbook:
```
---
- name: Install Nginx
  hosts: all
  become: true

  tasks:

    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

Run again:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/install_nginx.yml
```

Verify:
```bash
systemctl status nginx
```

## Create a User Automatically
Create:
```bash
nano ansible/playbooks/users.yml
---
- name: Create Users
  hosts: all
  become: true

  tasks:

    - name: Create devops user
      user:
        name: devopsuser
        shell: /bin/bash
        state: present
```

Run:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/users.yml
```

Verify:
```bash
grep devopsuser /etc/passwd
```
devopsuser created successfully

## Deploy a File
Create:
```bash
mkdir -p ansible/files
```

Create:
```bash
nano ansible/files/motd.txt
Managed by Ansible
```

Create Playbook:
```bash
nano ansible/playbooks/deploy_file.yml
---
- name: Deploy MOTD
  hosts: all
  become: true

  tasks:
    - name: Copy MOTD
      copy:
        src: ../files/motd.txt
        dest: /tmp/motd.txt
```

Run:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/deploy_file.yml
```

Verify:
```bash
cat /tmp/motd.txt
```

## Sysadmin Exercise
Create:
```bash
nano ansible/playbooks/hardening.yml
---
- name: Basic Hardening
  hosts: all
  become: true

  tasks:

    - name: Ensure UFW installed
      apt:
        name: ufw
        state: present

    - name: Allow SSH
      ufw:
        rule: allow
        port: "22"

    - name: Enable firewall
      ufw:
        state: enabled
```

Run:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/hardening.yml
```

## Create a Full Server Build Playbook

Create:
```bash
nano ansible/playbooks/server_build.yml
---
- name: Build Server
  hosts: all
  become: true

  tasks:

    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Ensure nginx started
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Create devops user
      user:
        name: devopsuser
        shell: /bin/bash
        state: present
```

## Core Concepts Review

- Infrastructure as Code
- Ansible Inventory
- Playbooks
- Idempotency

## Commands

- ansible
- ansible-playbook

## Playbooks Created

- install_nginx.yml
- users.yml
- deploy_file.yml
- server_build.yml

# Stretch Goals

## Install Package From Variables
Research:
```
vars:
  packages:
    - nginx
    - curl
    - git
```
Loop through package installation.

Loop through user creation:
```
loop:
  - user1
  - user2
  - user3
```

Use Templates:
```
template:
```

This Module will be important later

## DevOps Challenge

Instead of:
```bash
sudo apt install nginx
sudo systemctl start nginx
sudo ufw allow 80/tcp
```

Create a playbook that does all three

Then Destroy the configuration and reun the playbook

If ansible restores everything correctly, successful Infrastructure as Code Test.

Created/updated intall_nginx.yml:
```bash
---
- name: Install Nginx
  hosts: all
  become: true

  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes

    - name: UFW allow nginx
      ufw:
        rule: allow
        port: "80"
        proto: tcp
```

Disabled service/deleted ufw rules.

Ran:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/install_nginx.yml
```

Verified:
- nginx service running
- ufw rules created for port 80
- Connectivity through windows browser


## End-of-day Success Checklist
- Install Ansible
- Create inventory
- Run ad-hoc commands
- Gather Facts
- Write playbooks
- install software with Ansible
- Create users with Ansible
- Deploy files with Ansible
- Configure services with Ansible
- Understand idempotency
- Commit Everything to Github
