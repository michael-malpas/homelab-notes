# Terraform CI/CD Demo

## Overview

This project demonstrates a production-inspired Infrastructure as Code (IaC) workflow using **Terraform**, **GitHub Actions**, **AWS**, and **Ansible**.

The goal is to provision AWS infrastructure using Terraform while automating validation, planning, and deployment through a CI/CD pipeline. Infrastructure changes are reviewed through pull requests before being automatically applied after merging into the `main` branch, following common DevOps practices.

The project is part of my ongoing DevOps homelab and is designed to showcase infrastructure automation, secure secret management, and CI/CD best practices rather than simply provisioning cloud resources.

---

# Architecture

```text
                        GitHub Repository
                               │
                               ▼
                      GitHub Actions Pipeline
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
 Terraform fmt        Terraform validate     Terraform plan
                                                     │
                                              Pull Request Review
                                                     │
                                              Merge into main
                                                     │
                                                     ▼
                                             Terraform Apply
                                                     │
                                                     ▼
                                                   AWS
                                                     │
                                                     ▼
                                              EC2 Infrastructure
                                                     │
                                                     ▼
                                           Ansible Configuration
```

---

# Features

* Infrastructure as Code using Terraform
* Automated infrastructure validation
* Automated Terraform execution plans
* Automated infrastructure deployment after merge
* AWS authentication through GitHub Secrets
* Environment-specific configuration using Terraform variable files
* Remote Terraform state stored in Amazon S3
* Terraform state locking using the S3 lockfile mechanism
* Infrastructure configuration using Ansible
* Modular GitHub Actions workflows
* YAML validation for workflow files

---

# Technologies Used

## Cloud

* AWS EC2
* AWS IAM
* Amazon S3

## Infrastructure as Code

* Terraform

## Configuration Management

* Ansible

## CI/CD

* GitHub Actions

## Operating System

* Ubuntu Server

---

# Repository Structure

```text
terraform-ci-demo/
│
├── .github/
│   └── workflows/
│       ├── ansible.yml
│       ├── secrets-test.yml
│       ├── terraform.yml
│       ├── terraform-apply.yml
│       └── yaml-lint.yml
│
├── ansible/
│   └── configure.yml
│
└── terraform/
    ├── backend.tf
    ├── main.tf
    ├── outputs.tf
    ├── variables.tf
    ├── inventory.tpl
    ├── userdata.sh
    └── environments/
```

---

# Terraform Resources

The Terraform configuration provisions AWS infrastructure including:

* EC2 instances
* Security Groups
* Remote Terraform state stored in Amazon S3
* Terraform lockfile support using S3

Terraform variables are defined in `variables.tf`, while environment-specific values are stored separately using `.tfvars` files. This allows the same Terraform configuration to be reused across multiple environments without modifying the infrastructure code.

---

# GitHub Actions Workflows

## terraform.yml

Runs during pull requests and performs infrastructure validation.

Stages include:

* Terraform formatting (`terraform fmt`)
* Terraform validation (`terraform validate`)
* Terraform planning (`terraform plan`)

This workflow ensures infrastructure changes are reviewed before deployment.

---

## terraform-apply.yml

Runs after approved code is merged into the `main` branch.

Stages include:

* Configure AWS credentials
* Initialize Terraform
* Apply infrastructure changes automatically

Separating planning from deployment reflects common enterprise Infrastructure as Code workflows.

---

## ansible.yml

Validates Ansible playbooks to catch syntax errors before configuration changes are deployed.

---

## yaml-lint.yml

Runs Yamllint against repository YAML files to maintain consistent formatting and reduce configuration errors.

---

## secrets-test.yml

Verifies that GitHub Actions can securely authenticate with AWS using repository secrets.

---

# How the CI/CD Pipeline Works

```text
Developer
     │
     ▼
Feature Branch
     │
     ▼
Pull Request
     │
     ▼
GitHub Actions

 • Terraform fmt
 • Terraform validate
 • Terraform plan

     │
     ▼
Code Review
     │
     ▼
Merge into main
     │
     ▼
GitHub Actions

 • Terraform Apply

     │
     ▼
AWS Infrastructure Updated
```

---

# Getting Started

## Prerequisites

* AWS account
* Terraform
* Git
* GitHub repository
* GitHub Actions enabled
* AWS IAM user with appropriate permissions

---

## Repository Configuration

Sensitive information is **not** stored in the repository.

GitHub Secrets are used for credentials such as:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

Environment-specific Terraform values are stored in environment variable files (for example, `dev.tfvars` or `prod.tfvars`) and supplied during deployment rather than committed directly into the Terraform configuration.

---

# Design Decisions

## Separate Terraform Plan and Apply

The project intentionally separates infrastructure validation from deployment.

Pull requests generate a Terraform execution plan so infrastructure changes can be reviewed before they are merged. Only after approval and merging into the `main` branch does GitHub Actions automatically apply the changes.

This mirrors the deployment workflow used by many engineering teams and reduces the risk of unintended infrastructure modifications.

---

## Remote Terraform State

Terraform uses a remote backend stored in Amazon S3.

Using remote state allows infrastructure to be managed consistently across multiple environments and CI runners while preventing state drift.

The project uses Terraform's modern S3 lockfile mechanism instead of the legacy DynamoDB locking approach.

---

## Environment Separation

Terraform variables are separated from infrastructure code.

This makes it possible to deploy different environments (such as development and production) using the same Terraform configuration while supplying different configuration values.

---

# Skills Demonstrated

* Infrastructure as Code (Terraform)
* AWS Infrastructure Provisioning
* Remote Terraform State Management
* Terraform State Locking
* GitHub Actions
* Continuous Integration
* Continuous Deployment
* Infrastructure Validation
* Infrastructure Review Workflows
* AWS IAM Authentication
* Secure Secret Management
* Ansible Configuration Management
* YAML Validation
* Git Feature Branch Workflow
* Technical Documentation

---

# Future Improvements

Planned enhancements include:

* GitHub Environments with deployment approvals
* OpenID Connect (OIDC) authentication for GitHub Actions
* Terraform modules
* Multiple deployment environments
* Infrastructure testing
* Automated security scanning
* Cost optimization checks
* Kubernetes deployment
* Monitoring and observability integration

---

# Lessons Learned

Building this project reinforced several important DevOps concepts:

* Infrastructure should be treated as version-controlled code.
* Validation and deployment should be separate stages within a CI/CD pipeline.
* Secrets should never be committed to source control.
* Infrastructure changes should be reviewed before deployment.
* Automation should improve reliability while maintaining operational safeguards.
* Well-documented projects are easier to maintain, troubleshoot, and demonstrate to prospective employers.

---

# License

This repository is provided for educational and portfolio purposes as part of my ongoing DevOps homelab.
