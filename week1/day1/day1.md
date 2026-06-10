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
- Cloned repo from github
- Created test.md
- Test commit to github
- Moved test.md into week1 folder
- commited changes to github

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

## Cloned github homelab-notes repo
```bash
git clone git@github.com/michael-malpas/homelab-notes.git
```

## Created test.md file
```bash
echo "# Test" > test.md
```

## Committed Change to git
```bash
git add .
git commit -m "Initial Test Commit"
git push
```
Received request for username, github was using https: url

## Updated Git to use ssh url
Retrieved ssh url from github.com
```bash
git remote -v
git remote set-url origin git@github.com:michael-malpas/homelab-notes.git
git remote -v
```

## Tested ssh auth to github
```bash
ssh -T git@github.com
```

## Moved test.md to week1 folder and git push
```bash
mv test.dm week1/
git add .
git commit -m "Test commit to change file structure"
git status
git push
```

## Updating Documentation and pushing to git
```bash
git add .
git commit -m "Updating Day 1 documentation"
git status
git push
```

---


## Notes

SSH access is working successfully
Git Access is working successfully
cloned repo and able to push changes successfully

Need to learn:
- Permissions
- users/groups
- service management

tomorrow.
