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
