# Day 6 - Git, Branching, Pull Requests, Intro to Infrastructure as Code

## Goals
- Understand Git Workflows
- Create and merge branches
- Resolve merge conflicts
- use .gitignore
- Understand infrastructure as Code
- Build a structured repository
- Create change documentation

## Review Current Repository
```bash
cd ~/homelab-notes
git status
git log --oneline
```

## Understanding Branches
```bash
git branch
```
Expected:
- main
Branches allow changes without changing main version.

## Create Branch
Create:
```bash
git checkout -b feature/day6-git-lab
git branch
```
Expected:
- * feature/day6-git-lab
- main

## Make Changes on the Branch
```bash
mkdir -p week1/day6
nano week1/day6/day6.md
```
Learning Git Branching

Created first feature branch.

## Compare Branches
```bash
git log --online --graph
```

## Merge Back to Main
```bash
git checkout main
git merge feature/day6-git-lab
```
delete branch:
```bash
git branch -d feature/day6-git-lab
```

## Learn .gitignore
Create:
```bash
nano .gitignore
*.log
*.tar.gz
*.tmp
```
Create test files:
```bash
touch test.log
touch backup.tar.gz
```
check:
```bash
git status
```
Verify:
```bash
git check-ignore -v test.log
```

## Create Merge Conflict
Create Branch
```bash
git checkout -b conflict-test
nano conflict.txt
Version A
```
Commit:
```bash
git add .
git commit -m "Version A"
```
Return to main:
```bash
git checkout main
```
Create
```bash
nano conflict.txt
Version B
```
Commit:
```bash
git add .
git commit -m "Version B"
```
Merge:
```bash
git merge conflict-test
```
Expected:
CONFLICT

## Resolve the Conflict
Open:
```bash
nano conflict.txt
```
We can see the two versions.

Edited to the correct version "Version A and Version B"

Complete Merge:
```bash
git add conflict.txt
git commit
```

## Infrastructure as Code Concepts
Create:
```bash
mkdir -p infrastructure
```

Create:
```bash
nano infrastructure/README.md
```

Add:
```bash
# Infrastructure

Future Infrastructure as Code files will live here.

Examples:

- Terraform
- Ansible
- Docker
- Kubernetes
```

## Create a Server Inventory
Create Directory:
```bash
mkdir -p inventory
```
Create Documentation
```bash
nano inventory/servers.md
# Homelab Servers

## ubuntu-devops-01

Purpose:
Primary Linux learning server

Services:
- SSH
- Nginx

OS:
Ubuntu Server
```

## Change Management Exercise
Create:
```bash
nano week1/day6/change-request.md
# Change Request

## Change

Install Nginx web server

## Reason

Learn Linux service management

## Risk

Low

## Rollback

sudo apt remove nginx

## Validation

systemctl status nginx
```

## End-of-day Success Checklist
- Create Branches
- Merge Branches
- Delete branches
- Resolve merge conflicts
- Use .gitignore
- Understand PR workflows
- Create a GitHub PR
- Organize repository structure
- Document infrastructure
- Understand IaC concepts
