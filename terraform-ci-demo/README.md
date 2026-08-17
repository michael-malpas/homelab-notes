# Terraform CI/CD Demo

## Table of Contents

### Project

* [Overview](#overview)
* [Architecture](#architecture)
* [Features](#features)
* [Technologies Used](#technologies-used)
* [Repository Structure](#repository-structure)
* [Authentication](#authentication)
* [Security Design Decisions](#security-design-decisions)

### Infrastructure

* [Terraform Resources](#terraform-resources)
* [Terraform Modules](#terraform-modules)
* [Network Architecture](#network-architecture)
* [Security Groups](#security-groups)
* [Application Compute](#application-compute)
* [GitHub Actions Workflows](#github-actions-workflows)
* [Quality Assurance](#quality-assurance)
* [How the CI/CD Pipeline Works](#how-the-cicd-pipeline-works)

### Deployment

* [Getting Started](#getting-started)
* [Repository Configuration](#repository-configuration)
* [Environment Separation](#environment-separation)

### Design

* [Design Decisions](#design-decisions)
* [Infrastructure Governance](#infrastructure-governance)
* [Cost Governance](#cost-governance)

### Screenshots

* [GitHub Actions Pipeline](#github-actions-pipeline)
* [Terraform Plan](#terraform-plan)
* [GitHub Environment Approval](#github-environment-approval)
* [AWS Architecture](#aws-architecture)
* [AWS EC2 Instances](#aws-ec2-instances)

### Portfolio

* [Skills Demonstrated](#skills-demonstrated)
* [Future Improvements](#future-improvements)
* [Lessons Learned](#lessons-learned)
* [Project Evolution](#project-evolution)
* [License](#license)

---

# Overview

This project demonstrates a production-inspired Infrastructure as Code (IaC) workflow using **Terraform**, **GitHub Actions**, **AWS**, and **Ansible**.

The project provisions AWS infrastructure with Terraform while automating validation, security scanning, planning, approval, and deployment through GitHub Actions.

Infrastructure changes are reviewed through pull requests before being promoted through Development and Production deployment workflows.

The infrastructure has evolved from a simple single-instance deployment into a more production-inspired architecture using:

* Terraform modules
* Separate Development and Production Terraform state
* Environment-specific configuration
* Amazon VPC networking
* Public and private subnets
* Application Load Balancing
* Auto Scaling Groups
* EC2 Launch Templates
* IAM roles and instance profiles
* GitHub Actions OIDC authentication
* Temporary AWS credentials
* Terraform quality gates
* TFLint
* Checkov
* Ansible
* AWS cost governance
* Standardized resource tagging

The project is part of my ongoing DevOps homelab and is intended to demonstrate enterprise-inspired infrastructure automation, cloud security, CI/CD workflows, and operational best practices.

The infrastructure is intentionally implemented at homelab scale while following patterns commonly used in larger production environments.

---

# Architecture

The current application architecture is:

```text
                         GitHub Repository
                                │
                                ▼
                       GitHub Actions CI/CD
                                │
                                ▼
                         GitHub OIDC
                                │
                                ▼
                         AWS IAM Role
                                │
                                ▼
                            Terraform
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
              ▼                 ▼                 ▼
           Network          Security            IAM
              │                 │                 │
              └─────────────────┼─────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
              Application ALB              ASG
                    │                       │
                    ▼                       ▼
              Target Group          Launch Template
                                            │
                                            ▼
                                    Private EC2 Instances
                                            │
                                            ▼
                                      Application
```

Traffic flows through the Application Load Balancer rather than directly to individual EC2 instances.

```text
Internet
   │
   │ HTTP / HTTPS
   ▼
Application Load Balancer
   │
   │ HTTP
   ▼
Target Group
   │
   ▼
Auto Scaling Group
   │
   ├───────────────┐
   ▼               ▼
EC2 Instance    EC2 Instance
Private         Private
Subnet          Subnet
```

The application instances are deployed into private subnets and are not intended to receive direct Internet traffic.

The ALB provides the public entry point and distributes traffic to healthy instances managed by the Auto Scaling Group.

---

# Features

* Infrastructure as Code using Terraform
* Modular Terraform architecture
* Dedicated Terraform modules for reusable infrastructure
* Amazon VPC networking
* Public and private subnets
* Application Load Balancer
* Application Target Group
* Auto Scaling Group
* EC2 Launch Template
* Private application instances
* Remote Terraform state stored in Amazon S3
* Separate Development and Production Terraform state
* Terraform state locking using S3 lockfiles
* Environment-specific Terraform configuration
* GitHub Actions CI/CD pipelines
* Automated Terraform formatting
* Automated Terraform validation
* Terraform linting with TFLint
* Infrastructure security scanning with Checkov
* Automated Terraform planning
* Pull request review workflow
* Manual Production approval gates
* GitHub OpenID Connect authentication
* IAM role-based AWS authentication
* Temporary AWS credentials via AWS STS
* EC2 IAM instance profiles
* IMDSv2 enforcement
* Encrypted EBS volumes
* Ansible configuration management
* YAML validation
* Secure secret management
* Standardized AWS resource tagging
* AWS Cost Allocation Tags
* AWS Budgets
* Cloud cost governance
* Infrastructure security hardening

---

# Technologies Used

## Cloud

* AWS VPC
* AWS EC2
* AWS Application Load Balancer
* AWS Auto Scaling
* AWS IAM
* Amazon S3
* AWS STS

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
terraform-ci-demo/
│
├── ansible/
│   ├── configure.yml
│   └── inventory.ini
│
├── README.md
│
└── terraform/
    │
    ├── backend/
    │   ├── dev.hcl
    │   └── prod.hcl
    │
    ├── environments/
    │   ├── dev.tfvars
    │   └── prod.tfvars
    │
    ├── modules/
    │   ├── alb/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── README.md
    │   │   └── variables.tf
    │   │
    │   ├── asg/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── README.md
    │   │   └── variables.tf
    │   │
    │   ├── iam/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── README.md
    │   │   └── variables.tf
    │   │
    │   ├── network/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── README.md
    │   │   └── variables.tf
    │   │
    │   └── security_groups/
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── README.md
    │       └── variables.tf
    │
    ├── backend.tf
    ├── main.tf
    ├── outputs.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── inventory.tpl
    └── userdata.sh
```

The repository no longer uses a standalone EC2 Terraform module for application deployment.

Application compute is managed through the Auto Scaling Group and Launch Template.

---

# Authentication

The project originally authenticated GitHub Actions using long-lived IAM user access keys stored as GitHub Secrets.

As part of the security hardening process, the pipeline was migrated to **GitHub OpenID Connect (OIDC)** authentication.

The current authentication flow is:

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
Deployment IAM Role
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

This eliminates the need to store long-lived AWS access keys within GitHub.

Benefits include:

* No long-lived AWS credentials
* Temporary credentials issued by AWS STS
* Automatic credential expiration
* Improved auditability
* Reduced secret management
* Better separation of environments
* Support for least-privilege IAM policies

---

# Security Design Decisions

Security is incorporated throughout the infrastructure and deployment architecture.

## GitHub OIDC

GitHub Actions authenticates to AWS using OpenID Connect rather than long-lived IAM user access keys.

This provides short-lived credentials for CI/CD operations.

---

## Separate Deployment Roles

Development and Production deployments use separate IAM roles.

The homelab uses separate IAM identities to simulate an architecture that would commonly use separate AWS accounts in a larger organization.

Conceptually:

```text
Enterprise Model

Development AWS Account
        │
        └── Development IAM Role

Production AWS Account
        │
        └── Production IAM Role
```

The homelab simplifies this by implementing the separation within the same AWS account.

This allows the security and operational concepts of account separation to be demonstrated without the additional complexity and cost of maintaining multiple AWS accounts.

---

## EC2 IAM Role

The EC2 instances use a dedicated IAM role through an instance profile.

The EC2 role is separate from the GitHub Actions deployment role.

```text
GitHub Actions
      │
      ▼
Deployment IAM Role
      │
      ▼
Terraform

EC2
 │
 ▼
EC2 IAM Role
 │
 ▼
AWS APIs required by application
```

The EC2 role follows the principle of least privilege and should only contain permissions required by the application or configuration-management process.

---

## IMDSv2

EC2 instances require Instance Metadata Service Version 2.

The Launch Template configures:

```hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
```

Requiring IMDSv2 provides an additional layer of protection against credential-access techniques targeting the EC2 metadata service.

---

## Encrypted Storage

EC2 root volumes are configured to use encrypted EBS storage.

This protects data stored on the instance volumes and aligns with common cloud security practices.

---

## Network Segmentation

The application architecture separates public and private resources.

```text
Internet
   │
   ▼
Public Subnets
   │
   ▼
Application Load Balancer
   │
   ▼
Private Subnets
   │
   ▼
Application EC2 Instances
```

The application instances are not directly exposed to the Internet.

---

# Terraform Resources

The Terraform configuration provisions AWS infrastructure including:

* VPC networking
* Public subnets
* Private subnets
* Internet Gateway
* Routing
* Security Groups
* Application Load Balancer
* Target Group
* Auto Scaling Group
* EC2 Launch Template
* EC2 IAM instance profile
* Remote Terraform state stored in Amazon S3
* Terraform state locking using S3 lockfiles

Infrastructure configuration is separated from environment-specific deployment configuration through dedicated `.tfvars` files.

---

# Terraform Modules

The project uses reusable Terraform modules to improve organization, maintainability, and separation of responsibilities.

## Network Module

Responsible for networking infrastructure including:

* VPC
* Public subnets
* Private subnets
* Availability Zones
* Internet Gateway
* Route configuration

The network module provides the subnet IDs and networking information consumed by other modules.

---

## Security Groups Module

Security groups are managed through a dedicated module rather than being scattered throughout the root Terraform configuration.

The module provides separate security boundaries for components such as:

* Application Load Balancer
* Application instances

The intended traffic model is:

```text
Internet
   │
   ▼
ALB Security Group
   │
   ▼
Application Security Group
   │
   ▼
Private EC2
```

This prevents application instances from accepting arbitrary Internet traffic.

---

## IAM Module

The IAM module manages IAM resources required by the infrastructure.

This includes the EC2 application role and associated instance profile.

The GitHub OIDC deployment roles are kept conceptually separate from the EC2 runtime role because they serve different purposes.

---

## ALB Module

The ALB module manages:

* Application Load Balancer
* Target Group
* Listener
* Load balancer security-group association

The ALB provides the public application endpoint and distributes traffic to healthy instances in the Auto Scaling Group.

---

## ASG Module

The ASG module manages application compute.

It includes:

* Launch Template
* Auto Scaling Group
* Instance configuration
* IAM instance profile association
* Application security group association
* Private subnet placement
* Target Group association
* Health checks
* Instance tag propagation

The ASG is now the primary owner of application compute.

Individual EC2 instances are intentionally not managed as standalone Terraform resources.

This allows instances to be replaced automatically without requiring Terraform configuration changes.

---

# Network Architecture

The application uses a VPC containing separate public and private subnets.

```text
                         Internet
                            │
                            ▼
                     Internet Gateway
                            │
                 ┌──────────┴──────────┐
                 │                     │
                 ▼                     ▼
            Public Subnet A       Public Subnet B
                 │                     │
                 └──────────┬──────────┘
                            │
                            ▼
                  Application Load Balancer
                            │
                            ▼
                    Target Group
                            │
                 ┌──────────┴──────────┐
                 │                     │
                 ▼                     ▼
            Private Subnet A       Private Subnet B
                 │                     │
                 ▼                     ▼
              EC2 Instance          EC2 Instance
```

The ALB requires subnets in multiple Availability Zones.

The application Auto Scaling Group similarly uses multiple private subnets to improve availability and allow instances to be distributed across Availability Zones.

---

# Security Groups

Security groups are designed around application traffic rather than individual instances.

## ALB Security Group

The ALB security group permits the required public application traffic.

Typical rules include:

```text
Internet
   │
   ├── HTTP
   └── HTTPS
        │
        ▼
       ALB
```

---

## Application Security Group

The application security group does not directly permit arbitrary Internet traffic.

Instead, application traffic is accepted from the ALB security group.

```text
ALB Security Group
        │
        ▼
Application Security Group
        │
        ▼
       EC2
```

This provides a clear network security boundary between the public load balancer and private application infrastructure.

---

# Application Compute

Application compute is managed by an Auto Scaling Group rather than individual EC2 resources.

```text
                  Auto Scaling Group
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
       Launch Template        Desired Capacity
             │
             ▼
        Private EC2
```

The Launch Template defines the configuration used when instances are created.

This includes:

* AMI
* Instance type
* Security groups
* IAM instance profile
* User data
* EBS configuration
* Instance metadata configuration

The Auto Scaling Group manages:

* Minimum capacity
* Desired capacity
* Maximum capacity
* Private subnet placement
* Target Group association
* ELB health checks
* Instance replacement

Using an ASG makes individual instances disposable.

If an instance becomes unhealthy, the Auto Scaling Group can terminate and replace it without requiring a Terraform configuration change.

---

# GitHub Actions Workflows

## terraform-pr.yml

Runs during pull requests and validates infrastructure changes before deployment.

Stages include:

* Terraform formatting
* Terraform validation
* TFLint
* Checkov
* Terraform planning

Terraform planning occurs only after the automated quality gates successfully pass.

---

## terraform-apply.yml

Runs after changes are merged into the appropriate deployment branch and environment approval requirements are satisfied.

Stages include:

* Configure AWS credentials through GitHub OIDC
* Initialize Terraform
* Select the appropriate backend
* Apply the environment-specific Terraform configuration

Production deployment requires manual approval through GitHub Environment protection rules.

---

## ansible.yml

Validates Ansible playbooks to catch syntax errors before configuration changes are deployed.

---

## yaml-lint.yml

Runs Yamllint against repository YAML files to maintain consistent formatting and reduce configuration errors.

---

## secrets-test.yml

This workflow was used during the transition from IAM user access keys to GitHub OIDC authentication.

Long-lived AWS access keys are no longer required for normal CI/CD authentication.

---

# Quality Assurance

Infrastructure changes must pass automated quality gates before deployment.

The pipeline performs:

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
Merge
        │
        ▼
Deployment Approval
        │
        ▼
terraform apply
```

---

## Terraform Format

The pipeline runs:

```bash
terraform fmt -check -recursive
```

This ensures Terraform files follow standard formatting conventions.

---

## Terraform Validate

The pipeline runs:

```bash
terraform init
terraform validate
```

Validation checks Terraform configuration syntax, provider configuration, module references, and resource definitions.

---

## TFLint

TFLint performs static analysis against Terraform code.

It helps identify:

* Provider-specific issues
* Deprecated configurations
* Potential configuration mistakes
* Terraform best-practice violations

---

## Checkov

Checkov performs Infrastructure as Code security scanning.

Examples of checks include:

* Publicly exposed resources
* Insecure security groups
* Missing encryption
* IAM configuration issues
* EC2 security settings
* AWS best-practice violations

Security findings that are intentional for the homelab are documented rather than blindly suppressed.

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
    │
    ├── terraform fmt
    ├── terraform validate
    ├── TFLint
    ├── Checkov
    └── terraform plan
    │
    ▼
Code Review
    │
    ▼
Merge
    │
    ▼
terraform-apply.yml
    │
    ▼
GitHub OIDC
    │
    ▼
AWS IAM Role
    │
    ▼
Temporary AWS Credentials
    │
    ▼
Terraform Apply
    │
    ▼
AWS Infrastructure
```

Production deployment additionally requires GitHub Environment approval before Terraform Apply is permitted.

---

# Getting Started

## Prerequisites

* AWS account
* Terraform
* Git
* GitHub repository
* GitHub Actions enabled
* Appropriate AWS IAM roles
* SSH client
* Ansible

---

# Repository Configuration

Sensitive credentials are not stored in the repository.

GitHub Actions authenticates to AWS using GitHub OIDC.

Environment-specific Terraform configuration is stored separately:

```text
terraform/
└── environments/
    ├── dev.tfvars
    └── prod.tfvars
```

Terraform state is also separated between environments.

```text
Development
    │
    ▼
S3 Development State
    │
    └── dev infrastructure

Production
    │
    ▼
S3 Production State
    │
    └── prod infrastructure
```

This prevents a Production deployment from reusing or modifying Development Terraform state.

---

# Environment Separation

Development and Production use the same Terraform codebase but separate environment configuration and Terraform state.

Conceptually:

```text
                    Terraform Code
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
         Development             Production
              │                       │
         dev.tfvars              prod.tfvars
              │                       │
              ▼                       ▼
        dev backend              prod backend
              │                       │
              ▼                       ▼
       Dev Infrastructure       Prod Infrastructure
```

The homelab uses separate IAM roles to simulate the isolation that would commonly be achieved using separate AWS accounts.

A larger enterprise implementation could use:

```text
AWS Organization
       │
       ├── Development Account
       │       └── Development IAM Role
       │
       └── Production Account
               └── Production IAM Role
```

The homelab intentionally keeps these concepts within a simpler account structure to reduce cost and administrative overhead while still demonstrating the underlying security and deployment model.

---

# Design Decisions

## Separate Plan and Apply

Infrastructure validation and deployment are intentionally separated.

Pull requests execute automated quality checks and generate Terraform plans.

Deployment occurs only after the changes have been reviewed and merged.

Production additionally requires environment approval.

---

## Infrastructure Quality Gates

Terraform formatting, validation, linting, and security scanning must pass before a deployment plan is generated.

This creates a consistent baseline for infrastructure quality.

---

## GitHub Environment Protection

Production deployments use GitHub Environment protection rules.

This creates a manual approval checkpoint between automated CI and Production infrastructure changes.

---

## Remote Terraform State

Terraform state is stored remotely in Amazon S3.

Development and Production use separate state configurations.

The project uses the modern S3 lockfile mechanism rather than the legacy DynamoDB locking approach.

---

## Terraform Modules

Infrastructure responsibilities are divided into reusable Terraform modules.

Current modules include:

* Network
* Security Groups
* IAM
* ALB
* ASG

This structure allows individual infrastructure components to evolve without creating a single monolithic Terraform configuration.

---

## Auto Scaling Instead of Standalone EC2

The application originally used individually managed EC2 instances.

The architecture was refactored to use an Auto Scaling Group and Launch Template.

This provides:

* Instance replacement
* Health-based recovery
* Multiple instances
* Multi-AZ placement
* Load balancer integration
* Improved scalability

Individual EC2 instances are now treated as disposable compute resources rather than long-lived Terraform-managed infrastructure objects.

---

## Private Application Instances

Application instances are deployed into private subnets.

The Application Load Balancer provides the public entry point.

This reduces the attack surface and creates a more realistic production architecture.

---

## Least Privilege IAM

IAM policies are intentionally limited to the permissions required by each component.

GitHub deployment roles and EC2 runtime roles are separate because they have different responsibilities.

IAM policies will continue to evolve as the homelab introduces additional AWS services.

---

# Infrastructure Governance

Infrastructure should not only be automated—it should also be easy to operate, identify, and maintain.

Terraform uses standardized AWS resource tagging.

Common tags are configured through the AWS provider's `default_tags` mechanism.

Typical tags include:

| Tag            | Purpose                                     |
| -------------- | ------------------------------------------- |
| `Environment`  | Development or Production                   |
| `Project`      | Identifies the Terraform CI/CD Demo project |
| `Owner`        | Resource owner                              |
| `ManagedBy`    | Indicates Terraform management              |
| `Repository`   | Source GitHub repository                    |
| `CostCenter`   | Cost allocation                             |
| `AutoDeployed` | Indicates automated deployment              |

Resource-specific tags can be added where additional identification is useful.

The Auto Scaling Group also propagates appropriate tags to instances it launches.

---

# Cost Governance

The homelab incorporates basic AWS cost governance practices to prevent infrastructure experimentation from becoming unexpectedly expensive.

## Cost Allocation Tags

AWS Cost Allocation Tags are used to associate infrastructure costs with the appropriate project and environment.

This allows costs to be grouped and analyzed within AWS Cost Explorer.

---

## AWS Budgets

AWS Budgets are used to provide proactive notifications when spending approaches the configured threshold.

The goal is not to eliminate all cloud costs, but to provide an early warning system for unexpected resource consumption.

---

## Cost-Aware Infrastructure Design

The architecture intentionally balances production-inspired design with homelab cost constraints.

Examples include:

* Using a small number of EC2 instances
* Using appropriately sized instance types
* Avoiding unnecessary managed services
* Using separate IAM users/roles instead of maintaining multiple AWS accounts
* Treating multi-account architecture as an enterprise concept while implementing it at homelab scale

---

# Skills Demonstrated

* AWS Infrastructure Provisioning
* Infrastructure as Code
* Terraform
* Terraform Modules
* Terraform Remote State
* Terraform State Locking
* Environment Separation
* Amazon VPC
* Public and Private Subnets
* Application Load Balancing
* Auto Scaling Groups
* EC2 Launch Templates
* EC2 Instance Profiles
* AWS IAM
* IAM Least Privilege
* AWS STS
* GitHub Actions
* GitHub Environment Protection
* GitHub OpenID Connect
* Temporary Cloud Credentials
* Continuous Integration
* Continuous Deployment
* Infrastructure Quality Gates
* Terraform Formatting and Validation
* Terraform Linting
* TFLint
* Checkov
* Infrastructure Security Scanning
* Network Security
* Security Group Design
* IMDSv2
* EBS Encryption
* Ansible Configuration Management
* YAML Validation
* Git Feature Branch Workflow
* AWS Resource Tagging
* AWS Cost Governance
* AWS Budgets
* Cost Allocation Tags
* Terraform Provider `default_tags`
* Infrastructure Governance
* Technical Documentation

---

# Future Improvements

The next major phase of the project will begin introducing **Docker** into the existing infrastructure architecture.

Planned improvements include:

* Containerizing the application
* Building Docker images
* Running Docker containers on the EC2 instances
* Integrating Docker with the existing Auto Scaling architecture
* Improving container deployment automation
* Container image security scanning
* Application health checks
* Automated image builds through GitHub Actions
* Application Load Balancer integration with containerized workloads

Longer-term improvements may include:

* Automated cost anomaly detection
* AWS Cost and Usage Reports
* Policy-as-Code using Open Policy Agent
* Route 53 and DNS
* TLS certificate management
* Multi-account AWS deployment
* Kubernetes
* Prometheus/Grafana monitoring
* Centralized logging
* Advanced Terraform testing
* Container orchestration

---

# Lessons Learned

Building this project reinforced several important DevOps concepts:

* Infrastructure should be treated as version-controlled code.
* Validation, planning, and deployment should be separate stages within a CI/CD pipeline.
* Secrets should never be committed to source control.
* Short-lived credentials are preferred over long-lived access keys.
* GitHub OIDC provides a modern approach to CI/CD cloud authentication.
* Infrastructure changes should be reviewed before deployment.
* Automated quality gates improve reliability and reduce deployment risk.
* Security scanning should be integrated into the development workflow.
* Least-privilege IAM requires continuous review rather than a one-time configuration.
* Public and private network boundaries reduce infrastructure exposure.
* Load balancers should communicate with application security groups rather than exposing application instances directly.
* Auto Scaling Groups allow individual instances to be treated as disposable infrastructure.
* Launch Templates provide a reusable definition for application compute.
* Infrastructure modules improve maintainability and reduce duplication.
* Separate Terraform state prevents environments from unintentionally managing each other's resources.
* Environment-specific configuration allows the same Terraform codebase to support multiple deployment targets.
* Production approval gates provide an additional operational safeguard.
* Cost governance is an important part of responsible cloud engineering.
* Production-inspired architecture can be implemented at homelab scale without reproducing every enterprise cost or operational requirement.
* Well-documented projects are easier to maintain, troubleshoot, and demonstrate to prospective employers.

---

# Project Evolution

This repository has intentionally been developed in iterative stages to demonstrate how infrastructure evolves as new DevOps practices are introduced.

Major milestones include:

1. Basic Terraform infrastructure deployment
2. Remote Terraform state with Amazon S3
3. CI/CD integration with GitHub Actions
4. Automated Terraform validation and planning
5. Environment-specific Terraform configuration
6. Separate Development and Production Terraform state
7. Modular Terraform architecture
8. VPC and subnet architecture
9. Private application networking
10. Dedicated security group module
11. Dedicated IAM module
12. Application Load Balancer
13. Auto Scaling Group architecture
14. EC2 Launch Template
15. Migration from IAM user credentials to GitHub OIDC
16. Environment-specific IAM deployment roles
17. GitHub Environment production approval
18. Terraform linting with TFLint
19. Infrastructure security scanning with Checkov
20. Automated infrastructure quality gates
21. AWS resource tagging and cost governance
22. Refactoring from standalone EC2 instances to Auto Scaling managed compute
23. Launch Template security hardening
24. IAM and Terraform dependency cleanup

The next major phase will transition the application workload toward Docker while retaining the Terraform, networking, IAM, ALB, ASG, and CI/CD foundations established during the previous phases.

---

# License

This repository is provided for educational and portfolio purposes as part of my ongoing DevOps homelab.
