# Day 28 Notes – Environment Promotion with GitHub Actions

## Overview

Today's lesson focused on extending the Terraform CI/CD pipeline to support **multi-stage deployments** using GitHub Actions and GitHub Environments.

Previously, the pipeline automatically deployed infrastructure using a single environment configuration. While this demonstrated Infrastructure as Code automation, it did not reflect how infrastructure is typically promoted through environments in a production setting.

The pipeline was redesigned to deploy infrastructure to the **Development** environment automatically after a successful merge while requiring **manual approval** before deploying the same Terraform code to **Production**.

This introduces the concept of **deployment promotion**, where infrastructure changes move through multiple environments before reaching production.

---

## Deployment Promotion

One of the primary concepts introduced today was deployment promotion.

Rather than deploying directly to Production, infrastructure changes now follow a controlled deployment path:

```text
Developer
    │
    ▼
Pull Request
    │
    ▼
Terraform Validation
    │
    ▼
Merge to Main
    │
    ▼
Deploy Development
    │
    ▼
Testing / Verification
    │
    ▼
Manual Approval
    │
    ▼
Deploy Production
```

This workflow significantly reduces deployment risk by ensuring infrastructure is first validated in a lower-risk environment before affecting production resources.

---

## GitHub Actions Job Dependencies

The deployment workflow was expanded to include multiple jobs.

The first job is responsible for deploying the Development environment.

Once that job completes successfully, a second job becomes eligible to run.

GitHub Actions manages this sequencing using the `needs:` keyword, allowing jobs to execute in a specific order rather than simultaneously.

This creates a simple deployment pipeline where Production cannot begin until Development has completed successfully.

---

## GitHub Environments

Today's lesson reinforced the purpose of GitHub Environments.

The Production deployment job is associated with the **Production** GitHub Environment, which is configured with deployment protection rules.

Instead of immediately executing the deployment, GitHub pauses the workflow and waits for approval from an authorized reviewer.

Only after approval is granted does the Production deployment continue.

This provides an additional operational safeguard while still allowing deployments to remain largely automated.

---

## Environment-Specific Deployments

Although both Development and Production deployments use the same Terraform code, they deploy using different configuration files.

Development:

```bash
terraform apply \
-var-file=environments/dev.tfvars
```

Production:

```bash
terraform apply \
-var-file=environments/prod.tfvars
```

This demonstrates one of Terraform's core strengths:

The infrastructure code remains identical while deployment behavior changes based on the supplied configuration.

---

## Infrastructure Code vs Deployment Process

An important realization from today's lesson is that Infrastructure as Code extends beyond writing Terraform resources.

A production-ready deployment also includes:

* Validation
* Planning
* Deployment sequencing
* Approval gates
* Environment separation
* Change management

The GitHub Actions workflow has now become an integral part of the infrastructure lifecycle rather than simply acting as a wrapper around Terraform commands.

---

## Enterprise Deployment Practices

Today's workflow more closely resembles how infrastructure is deployed within many organizations.

Typical enterprise deployment flow:

* Infrastructure changes are committed to a feature branch.
* Pull requests trigger automated validation and planning.
* Changes are reviewed before merging.
* Development environments are updated automatically.
* Production deployments require manual approval.
* The same Terraform code is reused across all environments.

While larger organizations may introduce additional environments such as QA or Staging, the underlying deployment principles remain the same.

---

## Benefits of Deployment Promotion

Separating Development and Production deployments provides several advantages:

* Reduces the likelihood of production outages.
* Allows infrastructure to be tested before production deployment.
* Supports controlled release processes.
* Encourages consistent deployment practices.
* Provides a clear audit trail of infrastructure changes.

These practices are fundamental to reliable Infrastructure as Code workflows.

---

## Key Concepts Learned

* Deployment promotion allows infrastructure to move through multiple environments.
* GitHub Actions jobs can be sequenced using the `needs:` keyword.
* GitHub Environments provide deployment protection through approval gates.
* The same Terraform code can safely deploy multiple environments using different variable files.
* CI/CD pipelines become part of the infrastructure lifecycle, not just deployment automation.
* Production deployments should include safeguards that balance automation with operational control.

---

## Takeaways

Today's lesson marked the transition from simply automating Terraform commands to designing a deployment workflow that reflects real-world DevOps practices.

The project now supports:

* Multi-stage GitHub Actions workflows.
* Automatic Development deployments.
* Manual approval before Production deployments.
* Environment-specific Terraform configuration.
* Sequential infrastructure promotion using a single Terraform codebase.

These enhancements improve the reliability, maintainability, and professionalism of the project while closely mirroring deployment patterns commonly used by DevOps teams managing production cloud infrastructure.
