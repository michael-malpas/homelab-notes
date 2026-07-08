# Day 24 Notes – Automating Terraform Apply After Merge

## Overview

Today's lesson focused on extending the Infrastructure as Code pipeline by introducing automated infrastructure deployment. Yesterday's workflow generated a Terraform execution plan during pull requests, allowing infrastructure changes to be reviewed before they were merged. Today, the deployment stage was added so that approved changes could be applied automatically after reaching the `main` branch.

This mirrors a common DevOps workflow where infrastructure changes are reviewed through code review before being deployed by an automated pipeline.

---

## Why Separate Planning and Applying?

Terraform provides two distinct stages:

* **terraform plan** – compares the desired configuration with the current infrastructure and displays the proposed changes without modifying any resources.
* **terraform apply** – executes those changes and updates the infrastructure.

Separating these stages improves safety by ensuring that infrastructure modifications are reviewed before deployment. Pull requests become the review point, while merges into `main` represent approval to deploy.

---

## Creating a Dedicated Deployment Workflow

Instead of expanding the existing Terraform validation workflow, a separate workflow file (`terraform-apply.yml`) was created.

This approach offers several advantages:

* Validation and deployment remain independent.
* Each workflow has a single responsibility.
* Troubleshooting becomes easier because failures occur in clearly defined stages.
* The pipeline more closely resembles enterprise CI/CD practices.

The deployment workflow is triggered only when code is pushed to the `main` branch.

---

## Authenticating with AWS

Before Terraform could manage AWS resources, GitHub Actions authenticated using repository secrets and variables.

Sensitive values such as AWS credentials were stored as **GitHub Secrets**, while non-sensitive configuration values such as the AWS region were stored as **GitHub Variables**.

This removes the need to store credentials inside the repository.

---

## Providing Terraform Variables

Previously, Terraform relied on a local `terraform.tfvars` file.

As the project transitions to GitHub Actions, environment-specific values are now provided through environment variables using Terraform's `TF_VAR_` convention.

For example:

* `TF_VAR_aws_region`
* `TF_VAR_instance_type`
* `TF_VAR_key_name`
* `TF_VAR_my_ip`

Terraform automatically maps these environment variables to matching variables declared in `variables.tf`.

This allows the same Terraform code to run both locally and in GitHub Actions without committing environment-specific configuration files.

---

## Terraform Apply

After authentication and initialization, the workflow executes:

`terraform apply -auto-approve`

Because deployment only occurs after code has been reviewed and merged into `main`, the merge itself serves as the approval step. The pipeline can therefore deploy automatically without requiring additional interactive confirmation.

---

## Infrastructure Lifecycle

The project's infrastructure lifecycle now follows a complete CI/CD pattern:

1. Create a feature branch.
2. Make infrastructure changes.
3. Open a pull request.
4. GitHub Actions validates and generates a Terraform plan.
5. Review the proposed infrastructure changes.
6. Merge into `main`.
7. GitHub Actions automatically applies the approved changes.
8. When finished with the lab, manually destroy infrastructure from the local machine to avoid automating destructive operations.

---

## Key Concepts Learned

* Infrastructure changes should be reviewed before deployment.
* Pull requests are an ideal place to generate Terraform plans.
* Deployment should occur only after code has been approved.
* GitHub Actions can securely authenticate with AWS using repository secrets.
* Terraform variables can be injected through `TF_VAR_` environment variables instead of relying on local `.tfvars` files.
* Validation and deployment should be implemented as separate workflows.
* Destructive operations such as `terraform destroy` should remain manual in a learning environment to reduce operational risk.

---

## Takeaways

Today's lesson transformed the CI pipeline from a validation-only workflow into a deployment pipeline capable of automatically applying reviewed infrastructure changes. More importantly, it demonstrated that automation is most effective when paired with appropriate safeguards.

Rather than automating every action, mature DevOps workflows automate repetitive tasks while keeping high-risk operations deliberate and controlled. This balance between automation and operational safety is a defining characteristic of production-quality Infrastructure as Code.
