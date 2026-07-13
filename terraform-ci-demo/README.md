# Terraform CI/CD Demo

## Overview

This project demonstrates a production-inspired Infrastructure as Code (IaC) workflow using **Terraform**, **GitHub Actions**, **AWS**, and **Ansible**.

The project provisions AWS infrastructure using Terraform while automating validation, planning, and deployment through a CI/CD pipeline. Infrastructure changes are reviewed through pull requests before being deployed, with protected production approvals implemented using GitHub Environments.

As the project evolved, the Terraform configuration was refactored into reusable modules and extended to support multiple deployment environments, following practices commonly used by professional DevOps teams.

This repository is part of my ongoing DevOps homelab and focuses on building production-inspired automation rather than simply provisioning cloud resources.

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
                                           GitHub Environment
                                           (Production Approval)
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
* Reusable Terraform modules
* Multi-environment deployments using environment-specific variable files
* Automated Terraform validation
* Automated Terraform execution plans
* Protected production deployments using GitHub Environments
* AWS authentication using GitHub Secrets
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

## Version Control

* Git
* GitHub

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
    │
    ├── environments/
    │   ├── dev.tfvars
    │   └── prod.tfvars
    │
    └── modules/
        └── ec2/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

---

# Terraform Resources

The Terraform configuration provisions AWS infrastructure including:

* EC2 instances
* Security Groups
* Remote Terraform state stored in Amazon S3
* Terraform state locking using the S3 lockfile mechanism

Infrastructure configuration remains separate from deployment configuration through the use of environment-specific Terraform variable files.

---

# Terraform Modules

The project uses Terraform modules to improve code organization and reusability.

The EC2 instance configuration has been refactored into a reusable child module while the root module remains responsible for provider configuration, networking resources, environment-specific configuration, and module orchestration.

This modular design reduces duplication, improves readability, and makes the infrastructure easier to extend as additional AWS resources are introduced.

---

# GitHub Actions Workflows

## terraform.yml

Runs during pull requests and validates infrastructure changes before deployment.

Stages include:

* Terraform formatting (`terraform fmt`)
* Terraform validation (`terraform validate`)
* Terraform planning (`terraform plan`)

This workflow allows infrastructure changes to be reviewed before deployment.

---

## terraform-apply.yml

Runs after code has been merged into the `main` branch and deployment has been approved through the configured GitHub Environment.

Stages include:

* Configure AWS credentials
* Initialize Terraform
* Terraform Apply

The workflow uses GitHub Environment protection rules to require manual approval before infrastructure changes are deployed, adding an additional safeguard for production infrastructure.

---

## ansible.yml

Validates Ansible playbooks to catch syntax errors before configuration changes are deployed.

---

## yaml-lint.yml

Runs Yamllint against repository YAML files to maintain consistent formatting and reduce configuration errors.

---

## secrets-test.yml

Verifies that GitHub Actions can successfully authenticate with AWS using repository secrets.

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
GitHub Environment

     │
     ▼
Manual Approval

     │
     ▼
Terraform Apply

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

# Repository Configuration

Sensitive information is **never stored within the repository**.

GitHub Secrets are used for credentials such as:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

Environment-specific configuration is stored in Terraform variable files such as:

* `dev.tfvars`
* `prod.tfvars`

This allows the same Terraform codebase to deploy multiple environments while keeping infrastructure code separate from deployment configuration.

---

# Design Decisions

## Separate Terraform Plan and Apply

Infrastructure validation and deployment are intentionally separated.

Pull requests generate Terraform execution plans, allowing infrastructure changes to be reviewed before deployment.

Only after approval and merging into the `main` branch does the deployment workflow execute.

This mirrors common enterprise Infrastructure as Code workflows and reduces deployment risk.

---

## GitHub Environment Protection

Production deployments are protected using GitHub Environments.

Infrastructure changes require manual approval before Terraform Apply is allowed to execute.

Introducing deployment approval gates helps reduce operational risk while maintaining the benefits of automation.

---

## Remote Terraform State

Terraform stores its remote state within Amazon S3.

Using remote state allows infrastructure to be managed consistently across multiple environments and CI runners while preventing state drift.

The project uses Terraform's modern S3 lockfile mechanism instead of the legacy DynamoDB locking approach.

---

## Terraform Modules

Reusable Terraform modules improve maintainability by separating reusable infrastructure from deployment logic.

The root module coordinates infrastructure while child modules provision specific resources such as EC2 instances.

This approach reduces duplication and simplifies future expansion.

---

## Environment Separation

The project uses a single Terraform codebase for both Development and Production environments.

Environment-specific configuration is supplied using dedicated `.tfvars` files rather than maintaining separate Terraform projects.

This minimizes duplication while ensuring infrastructure changes remain consistent across environments.

---

# Screenshots

## GitHub Actions Pipeline

<p><img width="371" height="324" alt="image" src="https://github.com/user-attachments/assets/55102379-814c-4d69-8c52-b9de76fee36b" /></p>
<p><img width="321" height="509" alt="image" src="https://github.com/user-attachments/assets/a4431f7e-1b60-4e61-9c3a-dceeea667183" /></p>
<p><img width="314" height="430" alt="image" src="https://github.com/user-attachments/assets/568bb9fb-3cdc-4942-b282-487c57eff721" /></p>
<p><img width="318" height="370" alt="image" src="https://github.com/user-attachments/assets/62240b42-5933-401c-8f75-eb6eb416b32c" />
</p>
<p><img width="322" height="320" alt="image" src="https://github.com/user-attachments/assets/8650c134-60dd-4fee-acbf-2a409103285c" />
</p>

---

## Terraform Plan

<img width="602" height="791" alt="image" src="https://github.com/user-attachments/assets/d8c049c0-821a-41cd-bbfa-cc63f23f484a" />
<img width="602" height="763" alt="image" src="https://github.com/user-attachments/assets/ce3d7b40-769c-4449-b115-0e2946f1374c" />
<img width="601" height="778" alt="image" src="https://github.com/user-attachments/assets/8148386c-95cd-4096-a262-efbd47a78eb4" />
<img width="604" height="779" alt="image" src="https://github.com/user-attachments/assets/de4c43a2-07c6-4228-8577-66c217c06c6e" />
<img width="602" height="762" alt="image" src="https://github.com/user-attachments/assets/215d53b7-503e-4906-aea5-b8c26c02b096" />
<img width="600" height="130" alt="image" src="https://github.com/user-attachments/assets/c5997006-13f8-474d-88c5-8669f39b957d" />


---

## GitHub Environment Approval

<img width="1551" height="682" alt="image" src="https://github.com/user-attachments/assets/efe8c319-4345-4503-9c30-8a640f48d9db" />
<img width="630" height="380" alt="image" src="https://github.com/user-attachments/assets/d93cb42d-d3e4-4c88-9966-7b5ee50dcba9" />


---

## AWS EC2 Instance

<img width="1027" height="165" alt="image" src="https://github.com/user-attachments/assets/8a9ddd8d-3b91-4531-8cb6-31981d333899" />


---

# Skills Demonstrated

* Infrastructure as Code (Terraform)
* Terraform Modules
* Multi-Environment Infrastructure
* AWS Infrastructure Provisioning
* Remote Terraform State Management
* Terraform State Locking
* GitHub Actions
* Continuous Integration
* Continuous Deployment
* Deployment Approvals
* GitHub Environments
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

* OpenID Connect (OIDC) authentication for GitHub Actions
* Terraform module registry structure
* Infrastructure testing
* Automated security scanning
* Cost optimization monitoring
* AWS Load Balancer integration
* Route 53 DNS management
* TLS certificate management
* Kubernetes deployment
* Monitoring and observability integration

---

# Lessons Learned

Building this project reinforced several important DevOps concepts:

* Infrastructure should be treated as version-controlled code.
* Validation and deployment should be separate stages within a CI/CD pipeline.
* Secrets should never be committed to source control.
* Infrastructure changes should be reviewed before deployment.
* Modular infrastructure is easier to maintain than large monolithic Terraform configurations.
* Separating configuration from infrastructure code enables consistent multi-environment deployments.
* Deployment approvals provide an additional layer of operational safety for automated infrastructure changes.
* Automation should improve reliability while maintaining appropriate operational safeguards.
* Well-documented projects are easier to maintain, troubleshoot, and demonstrate to prospective employers.

---

# License

This repository is provided for educational and portfolio purposes as part of my ongoing DevOps homelab.
