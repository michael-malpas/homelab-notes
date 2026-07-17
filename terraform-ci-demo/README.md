# Terraform CI/CD Demo

## Overview

This project demonstrates a production-inspired Infrastructure as Code (IaC) workflow using **Terraform**, **GitHub Actions**, **AWS**, and **Ansible**.

The project provisions AWS infrastructure with Terraform while automating validation, planning, approval, and deployment through GitHub Actions. Infrastructure changes are reviewed through pull requests before being promoted through Development and Production deployment workflows.

The repository has evolved beyond basic infrastructure provisioning and now incorporates several modern DevOps practices, including:

* Infrastructure as Code using Terraform
* Modular Terraform architecture
* Remote Terraform state stored in Amazon S3
* Environment-specific deployments
* GitHub Actions CI/CD pipelines
* Manual approval gates for Production
* OpenID Connect (OIDC) authentication with AWS
* IAM role-based deployments using temporary credentials
* Infrastructure validation and YAML linting
* Ansible configuration management

The project is part of my ongoing DevOps homelab and is intended to demonstrate enterprise-inspired infrastructure automation, cloud security, CI/CD workflows, and operational best practices.

---

# Architecture

```text
                         GitHub Repository
                                │
                                ▼
                      Pull Request / Merge
                                │
                                ▼
                     GitHub Actions Workflows
                                │
        ┌───────────────────────┼────────────────────────┐
        │                       │                        │
        ▼                       ▼                        ▼
 Terraform fmt          Terraform validate      Terraform plan
                                │
                                ▼
                        Pull Request Review
                                │
                           Merge to main
                                │
                                ▼
                     GitHub OIDC Authentication
                                │
                                ▼
                  AWS IAM Role (Development)
                                │
                                ▼
                  Temporary AWS Credentials
                                │
                                ▼
                         Terraform Apply
                                │
                                ▼
                      AWS Infrastructure
                                │
                                ▼
                   Ansible Configuration
```
Note:
```text
Production deployments use a separate IAM role with GitHub Environment approval to simulate a multi-account enterprise deployment strategy.
```

---

# Features

- Infrastructure as Code using Terraform
- Modular Terraform architecture
- Remote Terraform state stored in Amazon S3
- Terraform state locking using S3 lockfiles
- Environment-specific configuration
- GitHub Actions CI/CD pipelines
- Automated Terraform formatting
- Automated Terraform validation
- Automated Terraform planning
- Automated Terraform deployment
- Pull request review workflow
- Manual Production approval gates
- GitHub OIDC authentication
- IAM role-based AWS authentication
- Temporary AWS credentials via AWS STS
- Infrastructure configuration with Ansible
- YAML validation
- Secure secret management

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
terraform-ci-demo
├── ansible
│   ├── configure.yml
│   └── inventory.ini
├── README.md
└── terraform
    ├── backend
    │   ├── dev.hcl
    │   └── prod.hcl
    ├── backend.tf
    ├── environments
    │   ├── dev.tfvars
    │   └── prod.tfvars
    ├── inventory.tpl
    ├── main.tf
    ├── modules
    │   └── ec2
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── README.md
    │       └── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    ├── userdata.sh
    └── variables.tf
```

---

# Authentication

The project originally authenticated GitHub Actions using long-lived IAM user access keys stored as GitHub Secrets.

As part of the security hardening process, the pipeline was migrated to **GitHub OpenID Connect (OIDC)** authentication.

Current authentication flow:

```text
GitHub Actions
        │
        ▼
OIDC Identity Token
        │
        ▼
AWS IAM Identity Provider
        │
        ▼
IAM Role
        │
        ▼
AWS STS
        │
        ▼
Temporary AWS Credentials
        │
        ▼
Terraform
```

This approach eliminates the need to store AWS access keys within GitHub and aligns the project with current AWS security best practices.

Benefits include:

* No long-lived AWS credentials
* Automatic credential rotation
* Improved auditability
* Reduced secret management
* Principle of least privilege

---

# Security Design Decisions

Several security-focused design decisions have been incorporated throughout the project.

## GitHub OIDC Authentication

GitHub Actions authenticates to AWS using OpenID Connect (OIDC) and temporary IAM role credentials instead of long-lived access keys.

## IAM Roles

Separate IAM roles are used for Development and Production deployments, simulating the authentication model commonly used in multi-account AWS environments.

## Remote State

Terraform state is stored remotely in Amazon S3 using the modern S3 lockfile mechanism.

## Secrets

Long-lived AWS credentials are no longer required by the CI/CD pipeline. Repository secrets are limited to non-sensitive configuration where appropriate.

## Deployment Promotion

Infrastructure changes are reviewed through pull requests before deployment. Production deployments require manual approval through GitHub Environments.

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

- AWS Infrastructure Provisioning
- Infrastructure as Code (Terraform)
- Modular Terraform Design
- Remote Terraform State Management
- Environment-specific Infrastructure
- GitHub Actions CI/CD
- Continuous Integration
- Continuous Deployment
- Infrastructure Validation
- Pull Request Based Deployment
- GitHub Environment Protection
- OpenID Connect (OIDC)
- IAM Roles
- AWS STS Temporary Credentials
- Secure Cloud Authentication
- Infrastructure Security
- Ansible Configuration Management
- YAML Validation
- Git Feature Branch Workflow
- Technical Documentation

---

# Future Improvements

Planned enhancements include:

- Least-privilege IAM policy refinement
- Infrastructure security scanning (Checkov, Trivy)
- Terraform linting (TFLint)
- Infrastructure testing
- Cost optimization and AWS Budgets
- Application Load Balancers
- Route 53 and DNS
- TLS certificate management
- Multi-account AWS deployment
- Kubernetes deployment
- Monitoring and observability (Prometheus/Grafana)
- Centralized logging

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

# Project Evolution

This repository has been intentionally developed in iterative stages to reflect how infrastructure evolves in real-world engineering environments.

Major milestones include:

1. Basic Terraform infrastructure deployment
2. Remote Terraform state with Amazon S3
3. CI/CD integration with GitHub Actions
4. Automated validation and planning workflows
5. Environment-specific configuration
6. Modular Terraform architecture
7. Manual deployment approvals
8. Migration from IAM user credentials to GitHub OIDC authentication
9. Environment-specific IAM roles using temporary AWS credentials

Future phases will focus on infrastructure security, policy enforcement, advanced AWS networking, Kubernetes, observability, and production-grade operational practices.

---

# License

This repository is provided for educational and portfolio purposes as part of my ongoing DevOps homelab.
