# Day 29 Notes – Environment Isolation with Separate Terraform State

## Overview

Today's lesson focused on one of the most important concepts in Infrastructure as Code: **Terraform state isolation**.

Although the project already supported multiple environments through separate Terraform variable files (`dev.tfvars` and `prod.tfvars`), both environments were still sharing a single remote Terraform state file.

This meant Terraform viewed the infrastructure as one deployment rather than two independent environments. Applying changes with different variable files could result in Development and Production unintentionally modifying the same infrastructure.

To solve this, the project was refactored so that each environment maintains its own remote Terraform state.

---

## Why Shared State Is a Problem

Before today's changes, both Development and Production used the same backend configuration.

The architecture looked similar to:

```text
Terraform Code
        │
        ▼
dev.tfvars
prod.tfvars
        │
        ▼
terraform.tfstate
```

Although different variable files were supplied during deployment, Terraform still tracked all resources inside one state file.

This created several risks:

* Development deployments could modify Production resources.
* Production deployments could overwrite Development changes.
* Infrastructure could not be managed independently.
* Environment isolation did not truly exist.

The `.tfvars` files only changed configuration values—they did not separate Terraform's understanding of the infrastructure.

---

## Separating Terraform State

The backend configuration was redesigned so that each environment now stores its own state independently.

The updated architecture is:

```text
Terraform Code
          │
          ├──────────────┐
          ▼              ▼
Development         Production
     │                  │
dev.tfvars         prod.tfvars
     │                  │
backend-config/    backend-config/
  dev.hcl            prod.hcl
     │                  │
development/       production/
terraform.tfstate  terraform.tfstate
```

Each environment now maintains its own record of managed infrastructure.

This allows Development and Production to evolve independently while still sharing the same Terraform codebase.

---

## Backend Configuration Files

Rather than hardcoding backend settings inside `backend.tf`, the backend block was simplified to:

```hcl
terraform {
  backend "s3" {}
}
```

Environment-specific backend settings are now stored separately:

* `backend-config/dev.hcl`
* `backend-config/prod.hcl`

Each backend configuration specifies:

* S3 bucket
* State file location
* AWS region
* Lockfile configuration

This approach keeps the Terraform configuration reusable while allowing different environments to use different remote state locations.

---

## Initializing Terraform

Terraform now selects the appropriate backend during initialization.

Development:

```bash
terraform init \
-reconfigure \
-backend-config=backend-config/dev.hcl
```

Production:

```bash
terraform init \
-reconfigure \
-backend-config=backend-config/prod.hcl
```

Using `terraform init` with a backend configuration file tells Terraform which remote state should be used before planning or applying infrastructure changes.

---

## State Migration

Because the project already contained managed infrastructure, changing the backend configuration required migrating the existing Terraform state.

Terraform automatically detected the backend change and prompted for state migration during initialization.

Accepting the migration preserved the existing Development infrastructure while relocating the state into its new location within the S3 backend.

No infrastructure resources were recreated.

Only the location of the Terraform state changed.

---

## GitHub Actions Updates

The GitHub Actions deployment workflow was also updated.

Previously, Terraform initialized using:

```bash
terraform init
```

Each deployment job now initializes Terraform using the appropriate backend configuration file before planning or applying changes.

Development:

```bash
terraform init \
-backend-config=backend-config/dev.hcl
```

Production:

```bash
terraform init \
-backend-config=backend-config/prod.hcl
```

This ensures that each deployment targets the correct Terraform state.

---

## Relationship Between Variables and State

One of the most important concepts learned today is the difference between Terraform variables and Terraform state.

Terraform variable files define **how infrastructure should be configured**.

Terraform state records **what infrastructure currently exists**.

Both are required.

Changing variable files alone does not create separate environments.

Separate environments require both:

* Environment-specific configuration
* Environment-specific state

---

## Preparing for Enterprise Infrastructure

Separating Terraform state is a common practice in enterprise Infrastructure as Code environments.

Although Development and Production currently reside within the same AWS account, today's architecture prepares the project for future improvements.

The next logical step is separating environments into different AWS accounts while continuing to use:

* Shared Terraform modules
* Shared Terraform code
* Independent Terraform state
* Independent deployment pipelines

This progression mirrors how many organizations gradually mature their cloud infrastructure.

---

## Key Concepts Learned

* Terraform state records the infrastructure currently under management.
* Variable files define configuration but do not separate infrastructure ownership.
* Development and Production should never share the same Terraform state.
* Backend configuration files allow different environments to use different remote state locations.
* `terraform init -backend-config` selects the appropriate backend before infrastructure operations begin.
* State migration allows backend changes without recreating existing infrastructure.
* Proper state isolation reduces operational risk and improves infrastructure maintainability.

---

## Takeaways

Today's lesson significantly improved the architecture of the Terraform project.

The project now supports:

* Shared Terraform code.
* Shared reusable Terraform modules.
* Environment-specific configuration.
* Environment-specific remote Terraform state.
* Independent infrastructure management for Development and Production.
* GitHub Actions workflows that initialize the correct backend for each deployment.

These improvements bring the project much closer to the Infrastructure as Code practices used by professional DevOps teams and establish a strong foundation for future enhancements such as multi-account AWS deployments and OpenID Connect (OIDC) authentication.

