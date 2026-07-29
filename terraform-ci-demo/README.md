# Terraform CI/CD Demo

## Table of Contents

### Project
- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Repository Structure](#repository-structure)
- [Authentication](#authentication)
- [Security Design Decisions](#security-design-decisions)
- [Security Highlights](#security-highlights)

### Infrastructure
- [Terraform Resources](#terraform-resources)
- [Terraform Modules](#terraform-modules)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Quality Assurance](#quality-assurance)
- [How the CI/CD Pipeline Works](#how-the-cicd-pipeline-works)

### Deployment
- [Getting Started](#getting-started)
- [Repository Configuration](#repository-configuration)

### Design
- [Design Decisions](#design-decisions)

### Screenshots
- [GitHub Actions Pipeline](#github-actions-pipeline)
- [Terraform Plan](#terraform-plan)
- [GitHub Environment Approval](#github-environment-approval)
- [AWS EC2 Instance](#aws-ec2-instance)

### Portfolio
- [Skills Demonstrated](#skills-demonstrated)
- [Future Improvements](#future-improvements)
- [Lessons Learned](#lessons-learned)
- [Project Evolution](#project-evolution)
- [License](#license)

## Overview

This project demonstrates a production-inspired Infrastructure as Code (IaC) workflow using **Terraform**, **GitHub Actions**, **AWS**, and **Ansible**.

The project provisions AWS infrastructure with Terraform while automating validation, security scanning, planning, approval, and deployment through GitHub Actions. Infrastructure changes are reviewed through pull requests before being promoted through Development and Production deployment workflows.

The repository has evolved beyond basic infrastructure provisioning and now incorporates several modern DevOps practices, including:

* Infrastructure as Code using Terraform
* Modular Terraform architecture
* Remote Terraform state stored in Amazon S3
* Environment-specific deployments
* GitHub Actions CI/CD pipelines
* Automated infrastructure quality gates
* Terraform formatting and validation
* Terraform linting with TFLint
* Infrastructure security scanning with Checkov
* Manual approval gates for Production
* OpenID Connect (OIDC) authentication with AWS
* IAM role-based deployments using temporary credentials
* Infrastructure configuration management using Ansible
* AWS cost governance tagging

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
                    GitHub Actions CI Pipeline
                                │
                                ▼
                         terraform-pr.yml
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
 Terraform fmt          Terraform validate           TFLint
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                                ▼
                            Checkov
                                │
                                ▼
                        Terraform plan
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

# AWS Network Architecture

```text
                           Internet
                              │
                              │
                         Internet Gateway
                              │
                              ▼

┌─────────────────────────────────────────────────────┐
│                    Custom VPC                       │
│                                                     │
│  CIDR: 10.0.0.0/16                                  │
│                                                     │
│                                                     │
│  ┌───────────────────────┐                          │
│  │   Public Subnet       │                          │
│  │   10.0.1.0/24         │                          │
│  │                       │                          │
│  │  ┌─────────────────┐  │                          │
│  │  │ Bastion Host    │  │                          │
│  │  │ Public IP       │  │                          │
│  │  │ Elastic IP      │  │                          │
│  │  └─────────────────┘  │                          │
│  │                       │                          │
│  └───────────┬───────────┘                          │
│              │                                      │
│              │ NAT Gateway                          │
│              │                                      │
│              ▼                                      │
│                                                     │
│  ┌───────────────────────┐                          │
│  │   Private Subnet      │                          │
│  │   10.0.2.0/24         │                          │
│  │                       │                          │
│  │  ┌─────────────────┐  │                          │
│  │  │ Internal Server │  │                          │
│  │  │ No Public IP    │  │                          │
│  │  └─────────────────┘  │                          │
│  │                       │                          │
│  └───────────────────────┘                          │
│                                                     │
└─────────────────────────────────────────────────────┘


Traffic Flow:

SSH Administration:
Internet
   │
   ▼
Bastion Host
   │
   ▼
Private Internal Server


Outbound Updates:
Private Server
   │
   ▼
NAT Gateway
   │
   ▼
Internet Gateway
   │
   ▼
Internet
```

The infrastructure follows a segmented network design using public and private subnets. Public-facing resources are isolated from internal workloads, while private instances access external services through a NAT Gateway without requiring public IP addresses.

Production environments are intended to follow the same architecture pattern using separate AWS accounts and Terraform state files.

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
- Terraform linting with TFLint
- Infrastructure security scanning with Checkov
- Automated Terraform planning after quality gates pass
- Pull request review workflow
- Manual Production approval gates
- GitHub OIDC authentication
- IAM role-based AWS authentication
- Temporary AWS credentials via AWS STS
- Infrastructure configuration with Ansible
- YAML validation
- Secure secret management
- Standardized resource tagging using Terraform locals
- AWS Cost Explorer integration through cost allocation tags
- AWS Budgets for proactive cost monitoring
- Centralized common tags applied across infrastructure
- Separate Development and Production IAM roles
- Customer-managed IAM policies
- IAM policy validation using IAM Access Analyzer
- Modular Terraform architecture
- Custom AWS VPC architecture
- Public and private subnet segmentation
- Private networking using isolated subnets
- NAT Gateway for private subnet outbound internet access
- Elastic IP allocation for public networking components
- Bastion host architecture for secure private instance access
- Network segmentation between public and private workloads

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

## Security and Quality Tools

* TFLint
* Checkov
* Yamllint

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
│   ├── configure.yml
│   └── inventory.ini
├── README.md
└── terraform
    ├── backend
    │   ├── dev.hcl
    │   └── prod.hcl
    ├── backend.tf
    ├── environments
    │   ├── dev.tfvars
    │   └── prod.tfvars
    ├── inventory.tpl
    ├── main.tf
    ├── modules
    │   └── ec2
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── README.md
    │       └── variables.tf
    ├── locals.tf
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
Development / Production IAM Role
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

Customer-managed IAM policies are used instead of broad AWS managed policies.

Least privilege is applied using a methodical approach of adding minimal permissions and expanding permissions only when required.

The policy will continue evolving as additional AWS services are introduced.

### IAM Access Analyzer

IAM Access Analyzer is used to validate customer-managed IAM policies and identify opportunities to further reduce permissions.

Rather than granting broad administrative access, IAM policies are iteratively refined based on deployment requirements and Access Analyzer recommendations. This approach helps ensure the GitHub Actions deployment roles maintain only the permissions necessary to provision the infrastructure.

This mirrors how IAM policies are commonly developed and maintained within enterprise AWS environments.

## Remote State

Terraform state is stored remotely in Amazon S3 using the modern S3 lockfile mechanism.

## Cloud Cost Governance

Cloud resources should be easy to identify, manage, and attribute to the correct environment or project. To support this, all infrastructure created by Terraform follows a standardized tagging strategy.

A centralized set of common tags is defined using Terraform locals and automatically applied across resources using the merge() function. This reduces duplication while ensuring consistent metadata is attached to every resource.

| Tag | Purpose |
|------|---------|
| Name | Human-readable resource name |
| Environment | Development or Production environment |
| Project | Identifies the Terraform CI/CD Demo project |
| Owner | Resource owner |
| ManagedBy | Indicates Terraform manages the resource |
| Repository | Source GitHub repository |
| CostCenter | Used for cost allocation |
| AutoDeployed | Indicates infrastructure was deployed through automation |

These tags improve:

- Resource ownership
- Cost reporting
- Inventory management
- Automation
- Operational consistency

AWS Cost Allocation Tags are enabled so costs can be grouped by project and environment within AWS Cost Explorer.

An AWS Budget is also configured to notify when monthly spending approaches the defined threshold, encouraging proactive cloud cost management.

## Secrets

Long-lived AWS credentials are no longer required by the CI/CD pipeline. Repository secrets are limited to non-sensitive configuration where appropriate.

## Deployment Promotion

Infrastructure changes are reviewed through pull requests before deployment. Production deployments require manual approval through GitHub Environments.

---

# Security Highlights

The project incorporates several modern AWS security practices:

- GitHub OpenID Connect (OIDC) authentication
- Temporary AWS STS credentials
- Separate Development and Production IAM roles
- Customer-managed IAM policies
- Principle of least privilege
- IAM Access Analyzer policy validation
- Protected Production deployments through GitHub Environments
- Remote Terraform state stored securely in Amazon S3
- No long-lived AWS credentials stored in the repository

---

# Terraform Resources

The Terraform configuration provisions AWS infrastructure including:

## Networking

* Custom Amazon VPC
* Public subnet
* Private subnet
* Internet Gateway
* NAT Gateway
* Elastic IP allocation
* Route tables
* Route table associations

## Compute

* EC2 instances
* Bastion host
* Private internal server
* Security Groups

## State Management

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

## terraform-pr.yml

Runs during pull requests and validates infrastructure changes before deployment.

This workflow acts as the primary infrastructure quality gate before changes are approved and merged.

Stages include:

* Terraform formatting (`terraform fmt`)
* Terraform validation (`terraform validate`)
* Terraform linting (`TFLint`)
* Infrastructure security scanning (`Checkov`)
* Terraform planning (`terraform plan`)

Terraform planning only occurs after all automated quality gates successfully pass.

This workflow allows infrastructure changes to be reviewed before deployment and prevents invalid or insecure configurations from progressing through the pipeline.

---

## terraform-apply.yml

Runs after code has been merged into the `main` branch and deployment has been approved through the configured GitHub Environment.

Stages include:

* Configure AWS credentials through GitHub OIDC
* Initialize Terraform
* Terraform Apply

The workflow uses GitHub Environment protection rules to require manual approval before infrastructure changes are deployed, adding an additional safeguard for production infrastructure.

---

## ansible.yml

Validates Ansible playbooks to catch syntax errors before configuration changes are deployed.

Stages include:

* Ansible syntax validation
* Playbook validation

---

## yaml-lint.yml

Runs Yamllint against repository YAML files to maintain consistent formatting and reduce configuration errors.

---

## secrets-test.yml

Verifies that GitHub Actions can successfully authenticate with AWS using repository secrets.

This workflow was used during the migration from IAM user access keys to GitHub OIDC authentication.

---

# Quality Assurance

Before infrastructure changes can be deployed, Terraform code must pass automated quality gates to ensure consistency, validity, security, and maintainability.

The CI/CD pipeline performs multiple validation stages before a Terraform deployment plan is generated.

Infrastructure changes must successfully pass all automated quality checks before a deployment plan is created.

---

## Terraform Format

Terraform formatting ensures that all Terraform configuration files follow standard HashiCorp formatting conventions.

The pipeline runs:

```bash
terraform fmt -check -recursive
```

This verifies that Terraform files are consistently formatted before changes are reviewed.

Benefits:

* Maintains consistent code style
* Improves readability
* Reduces unnecessary formatting changes in pull requests
* Ensures Terraform follows community standards

---

## Terraform Validate

Terraform validation checks whether the Terraform configuration is syntactically correct and internally consistent.

The pipeline runs:

```bash
terraform init
terraform validate
```

Validation verifies:

* Terraform configuration syntax
* Provider configuration
* Resource definitions
* Module references
* Variable usage

This prevents invalid Terraform configurations from progressing further in the deployment pipeline.

---

## TFLint

TFLint performs static analysis on Terraform code to identify potential issues beyond basic syntax validation.

TFLint checks for:

* Terraform best practices
* Provider-specific issues
* Deprecated configurations
* AWS-specific configuration recommendations
* Potential configuration mistakes

Example:

```bash
tflint
```

TFLint helps identify problems early before infrastructure changes are deployed.

---

## Checkov

Checkov performs Infrastructure as Code security scanning against Terraform configurations.

The pipeline runs:

```bash
checkov -d .
```

Checkov evaluates infrastructure against security policies and cloud security best practices.

Examples of checks include:

* Publicly accessible resources
* Missing encryption settings
* Overly permissive security groups
* Insecure IAM configurations
* AWS security best practices

Security exceptions are documented explicitly when required for intentional lab or demonstration configurations.

---

## Deployment Quality Gate

All automated quality checks must successfully complete before a Terraform deployment plan is generated.

The workflow follows this sequence:

```text
Terraform Code Change
          │
          ▼
terraform fmt
          │
          ▼
terraform validate
          │
          ▼
TFLint
          │
          ▼
Checkov
          │
          ▼
terraform plan
          │
          ▼
Pull Request Review
          │
          ▼
Merge into main
          │
          ▼
Deployment Approval
          │
          ▼
terraform apply
```

This quality gate approach ensures that infrastructure changes are reviewed, validated, and security-checked before they are allowed to modify cloud resources.

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
terraform-pr.yml

 • Terraform fmt
 • Terraform validate
 • TFLint
 • Checkov
 • Terraform plan

     │
     ▼
Code Review
     │
     ▼
Merge into main
     │
     ▼
terraform-apply.yml

 • Configure AWS OIDC authentication
 • Terraform init
 • Manual approval

     │
     ▼
Terraform Apply

     │
     ▼
AWS

├── EC2
├── Security Groups
├── S3 Remote State
└── Cost Governance Tags

        │
        ▼
Ansible Configuration

```

---

# Getting Started

## Prerequisites

* AWS account
* Terraform
* Git
* GitHub repository
* GitHub Actions enabled
* AWS IAM permissions for infrastructure deployment

---

# Repository Configuration

Sensitive information is **never stored within the repository**.

GitHub Actions authentication uses GitHub OIDC with AWS IAM roles rather than long-lived access keys.

Environment-specific configuration is stored in Terraform variable files such as:

* `dev.tfvars`
* `prod.tfvars`

This allows the same Terraform codebase to deploy multiple environments while keeping infrastructure code separate from deployment configuration.

---

# Design Decisions

## Separate Terraform Plan and Apply

Infrastructure validation and deployment are intentionally separated.

Pull requests execute automated quality checks and generate Terraform execution plans, allowing infrastructure changes to be reviewed before deployment.

Only after approval and merging into the `main` branch does the deployment workflow execute.

This mirrors common enterprise Infrastructure as Code workflows and reduces deployment risk.

---

## Infrastructure Quality Gates

Infrastructure changes must pass automated validation and security checks before a deployment plan is generated.

The CI/CD pipeline validates:

* Terraform formatting
* Terraform configuration validity
* Terraform best practices
* Infrastructure security policies

This ensures infrastructure changes meet baseline quality and security standards before they can be reviewed or deployed.

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

## Infrastructure Governance

Infrastructure should not only be automated—it should also be easy to operate and maintain.

To support this, the project implements standardized tagging across all Terraform-managed resources. Common tags are defined once using Terraform locals and merged into individual resources to ensure consistency without duplicating configuration.

This approach simplifies resource discovery, enables cost allocation, improves operational visibility, and mirrors governance practices commonly used within enterprise cloud environments.

---

# Screenshots

## GitHub Actions Pipeline

<p><img width="371" height="324" alt="image" src="https://github.com/user-attachments/assets/55102379-814c-4d69-8c52-b9de76fee36b" /></p>

<p><img width="321" height="509" alt="image" src="https://github.com/user-attachments/assets/a4431f7e-1b60-4e61-9c3a-dceeea667183" /></p>

<p><img width="314" height="430" alt="image" src="https://github.com/user-attachments/assets/568bb9fb-3cdc-4942-b282-487c57eff721" /></p>

<p><img width="318" height="370" alt="image" src="https://github.com/user-attachments/assets/62240b42-5933-401c-8f75-eb6eb416b32c" /></p>

<p><img width="322" height="320" alt="image" src="https://github.com/user-attachments/assets/8650c134-60dd-4fee-acbf-2a409103285c" /></p>

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
- Infrastructure Quality Gates
- Terraform Formatting and Validation
- Terraform Linting with TFLint
- Infrastructure Security Scanning with Checkov
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
- AWS Resource Tagging
- Cloud Cost Governance
- AWS Budgets
- Cost Allocation Tags
- Terraform Locals
- Terraform merge() Function
- Infrastructure Governance
- AWS IAM Policy Design
- IAM Access Analyzer
- Principle of Least Privilege
- GitHub OIDC Federation
- AWS VPC Networking
- Public and Private Subnet Design
- NAT Gateway Configuration
- Elastic IP Management
- Bastion Host Architecture
- Network Security Design
- AWS Route Tables
- Infrastructure Network Segmentation

---

# Future Improvements

Planned enhancements include:

- Automated cost anomaly detection
- AWS Cost and Usage Reports (CUR)
- Policy-as-Code using Open Policy Agent (OPA)
- Application Load Balancers
- Route 53 and DNS
- TLS certificate management
- AWS Organizations and true multi-account architecture (potentially, understand principle but want to avoid costs)
- Kubernetes deployment
- Monitoring and observability (Prometheus/Grafana)
- Centralized logging
- Advanced Terraform testing frameworks

---

# Lessons Learned

Building this project reinforced several important DevOps concepts:

* Infrastructure should be treated as version-controlled code.
* Validation, planning, and deployment should be separate stages within a CI/CD pipeline.
* Secrets should never be committed to source control.
* Short-lived credentials are preferred over long-lived access keys.
* Infrastructure changes should be reviewed before deployment.
* Automated quality gates improve reliability and reduce deployment risk.
* Security scanning should be integrated into the development workflow rather than performed after deployment.
* Modular infrastructure is easier to maintain than large monolithic Terraform configurations.
* Separating configuration from infrastructure code enables consistent multi-environment deployments.
* Deployment approvals provide an additional layer of operational safety for automated infrastructure changes.
* Well-documented projects are easier to maintain, troubleshoot, and demonstrate to prospective employers.

---

# Project Evolution

This repository has been intentionally developed in iterative stages to reflect how infrastructure evolves in real-world engineering environments.

Major milestones include:

1. Basic Terraform infrastructure deployment
2. Remote Terraform state with Amazon S3
3. CI/CD integration with GitHub Actions
4. Automated Terraform validation and planning workflows
5. Environment-specific configuration
6. Modular Terraform architecture
7. Manual deployment approvals
8. Migration from IAM user credentials to GitHub OIDC authentication
9. Environment-specific IAM roles using temporary AWS credentials
10. Automated infrastructure quality gates
11. Terraform linting with TFLint
12. Infrastructure security scanning with Checkov
13. Cloud governance and standardized resource tagging
14. Least-privilege IAM with customer-managed policies and IAM Access Analyzer
15. Custom VPC Network with public and private subnets create
16. Internet and Nat gateway created
17. demonstrated that custom terraform modules can be used to create multiple resources and attach them to the correct subnets

Future phases will focus on infrastructure testing, advanced AWS networking, Kubernetes, observability, and production-grade operational practices.

---

# License

This repository is provided for educational and portfolio purposes as part of my ongoing DevOps homelab.
