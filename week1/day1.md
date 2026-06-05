# Day 1 - Ubuntu Server Setup

## Objective

Set up the first Linux server for my DevOps homelab.

---


## VM Information

Hostname:
ubuntu-devops-01

Operating System:
Ubuntu Server LTS

resources:
- 4 cpu
- 8 gb ram
- 60 gb disk

---


## Tasks completed

- Installed ubuntu server
- Enabled OpenSSH server
- updated Packages
- Configured SSH Access
- Created lab directories
- Setup SSH Access for github

---

## Commands Learned/practiced

```bash
whomami
```

## Check Hostname

```bash
hostname
```

### Show Current Directory

```bash
pwd
```

## List Files

```bash
ls
```

## Create Directories

```bash
mkdir lab notes scripts
```
## Generate SSH Key for Github

```bash
ssh-keygen -t ed25519 -C "email"
```
## Verifying ssh agent is running
```bash
eavl "$(ssh-agent -s)"
```

## Adding ssh and verifying it added successfully
```bash
ssh-add ~/.ssh/id_ed25519
ssh-add -l
```

## Viewing ssh public key to add to github
```bash
cat ~/.ssh/id_ed25519.pub
```

## Added ssh key to gitub
Settings > ssh keys > new key > ubuntu-devops-01 ssh access

---

## Notes

SSH access is working successfully

Need to learn:
- Permissions
- users/groups
- service management

tomorrow.
