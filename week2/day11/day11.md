# CI/CD with GitHub Actions

Up until now
```
Linux
Git
Bash
Networking
Ansible
Docker
Docker Compose
Monitoring
```

The Goal of CI/CD:
```
Developer makes change
        ↓
Pushes to GitHub
        ↓
Automation runs
        ↓
Tests pass
        ↓
Deployment happens
```

## Goals

- Understand CI/CD concepts
- Create GitHub Actions workflows
- Trigger Automation from Git pushes
- Validate files automatically
- run scripts automatically
- build docker containers automatically
- create deployment pipelines

## Build Plan
```
Git Push
    ↓
GitHub Actions
    ↓
Validation
    ↓
Docker Build
    ↓
Success/Failure Report
```

## CI/CD Concepts
CI (Continuous Integration)

Every code change gets automatically tested 

Example:
```
git push
    ↓
Run tests
    ↓
Pass/Fail
```

CD (Continuous Delivery)

Code is automatically prepared for deployment

Example:
```
git push
    ↓
Build application
    ↓
Deployable artifact created
```

Continuous Deployment

Code automatically goes into production

Example:
```
git push
    ↓
Tests pass
    ↓
Production updated
```

## Create Workflow Directory
Working in homelab-notes repository:
```bash
mkdir -p .github/workflows
```

Verify:
```bash
tree .github
```

Expected
```
.github
└── workflows
```

## Create First Workflow
Create:
```bash
nano .github/workflows/hello.yml
name: Hello Workflow

on:
  push:

jobs:
  hello:
    runs-on: ubuntu-latest

    steps:
      - name: Print Message
        run: echo "Hello DevOps!"
```

Save

## Commit and Push
```bash
git add.
git commit -m ""
git push
```

## View action
Go to:

Github Actions Documentation or open repository and click "Actions"

You should see:
```
Hello Workflow
```

Running.

## Create Real Validation Workflow

Delete hello.yml

Create:
```bash
nano .github/workflows/validate.yml
name: Validate Repository

on:
  push:

jobs:
  validate:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout
        uses: actions/checkout@v4

      - name: List Files
        run: ls -R

      - name: Validate Markdown
        run: find . -name "*.md"
```

Push to github

Observe action execution

## Create a Bash Validation Script
Create:
```bash
mkdir -p scripts
```

Create:
```bash
nano scripts/check_notes.sh
#!/bin/bash

echo "Checking markdown files..."

count=$(find . -name "*.md" | wc -l)

echo "Markdown files: $count"

if [ "$count" -lt 5 ]; then
    echo "Not enough documentation!"
    exit 1
fi

echo "Validation passed."
```

Make Executable:
```bash
chmod +x scripts/check_notes.sh
```

Test:
```bash
./scripts/check_notes.sh
```

## Execute Script in GitHub Actions

Update Workflow:
```
name: Validate Repository

on:
  push:

jobs:
  validate:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - name: Run Validation
        run: ./scripts/check_notes.sh
```

Push Changes

Observe Workflow

## Learn Workflow Failures
Intentionally break it.

Edit Script:
```bash
exit 1
```

Push

Observe:
```
Workflow Failed
```

Fix it

push it again.

Observe:
```
Workflow Passed
```

## Build a Docker Image Automatically
Create:
```bash
nano Dockerfile
FROM nginx

COPY html/index.html /usr/share/nginx/html/index.html
```

Create:
```bash
mkdir html
nano html/index.html
<h1>DevOps Pipeline Test</h1>
```

## Docker Build Workflow
Create:
```bash
nano .github/workflows/docker-build.yml
name: Docker Build

on:
  push:

jobs:

  docker:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - name: Build Docker Image
        run: docker build -t devops-test .
```

Push

Observe Workflow

## Multiple Jobs

Update:
```
name: Pipeline

on:
  push:

jobs:

  validate:

    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - run: ./scripts/check_notes.sh

  docker:

    runs-on: ubuntu-latest

    needs: validate

    steps:
      - uses: actions/checkout@v4

      - run: docker build -t devops-test .
```

Notice:
```
validate
     ↓
docker
```

## Repository Badges
Generate a workflow badge later from GitHub

Example:
```
Build: Passing
```

These are common in open-source projects

## DevOps Exercise
Create:
```bash
nano scripts/server_audit.sh
```

Collect:
- hostname
- uptime
- disk
- memory
- docker containers

Output:
```
Server Audit Complete
```
Run locally.

Create Workflow:
```yaml
- run: ./scripts/server_audit.sh
```

Operational Checks simulation

## Create README
update repository README

Include:
```
# DevOps Homelab

## Skills Covered

- Linux
- Git
- Bash
- Networking
- Ansible
- Docker
- Docker Compose
- Monitoring
- GitHub Actions

## Progress

- Week 1 Complete
- Week 2 In Progres
```

## Stretch Goal - Ansible Validation
Create a workflow that runs:
```
ansible-playbook --syntax-check playbook.yml
```

## Stretch Goal - Docker Compose validation
Add:
```bash
docker compose config
```
to a workflow.

This verifies compose files before deployment

## Stretch Goal - Challenge
Create a pipeline that:
1. Checks markdown documentation exists
2. Verifies Dockerfile builds
3. Validates Compose Syntax
4. Verifies Ansible playbook syntax

If any step fails:
```
Pipeline fails
```

If all pass:
```
Pipeline succeeds
```

This is a simplified infrastructure CI pipeline.

## End-of-day Success Checklist
- Understand CI/CD
- Create GitHub Actions workflow
- Trigger workflow on push
- Run scripts automatically
- Create validation checks
- Build Docker image automatically
- Create multi-job pipeline
- Document progress
- Push everything to github
