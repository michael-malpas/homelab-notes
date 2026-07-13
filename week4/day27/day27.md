# Day 27 Notes – Multi-Environment Terraform

## Overview

Today's lesson focused on extending the Terraform project to support **multiple deployment environments** while maintaining a single Infrastructure as Code (IaC) codebase.

Previously, the project relied on a single `terraform.tfvars` file that represented one environment. While this approach works for small projects, it does not scale well when different environments such as Development, Testing, and Production require different configuration values.

To solve this, environment-specific configuration was separated into dedicated variable files while keeping the Terraform code itself unchanged.

This demonstrates one of the core principles of Infrastructure as Code:

**One codebase, multiple environments.**

---

## Infrastructure Code vs Configuration

One of the most important concepts introduced today was the distinction between infrastructure code and configuration.

### Infrastructure Code

Infrastructure code defines **what resources should exist**.

Examples include:

* EC2 instances
* Security Groups
* IAM resources
* Networking
* Terraform modules

These resources remain identical regardless of the environment being deployed.

### Configuration

Configuration defines **how those resources should be deployed**.

Examples include:

* Environment name
* Instance type
* Number of instances
* Key pair name
* Region
* Allowed IP addresses

Rather than modifying Terraform code for each deployment, these values are supplied through environment-specific variable files.

Separating infrastructure from configuration improves maintainability and reduces duplication.

---

## Environment Variable Files

A new directory was created to store environment-specific configuration:

```text
terraform/
└── environments/
    ├── dev.tfvars
    └── prod.tfvars
```

Each file contains values appropriate for its environment while using the same Terraform configuration.

For example:

**Development**

* Smaller infrastructure
* Lower cost
* Used for testing

**Production**

* Production naming
* Potentially larger instance sizes
* Designed for live workloads

This structure allows new environments to be added without changing the Terraform code itself.

---

## Deploying Different Environments

Terraform can now deploy different environments by specifying the appropriate variable file.

For example:

Development:

```bash
terraform plan -var-file=environments/dev.tfvars
```

Production:

```bash
terraform plan -var-file=environments/prod.tfvars
```

Although the configuration values change, the underlying Terraform code remains exactly the same.

---

## Naming Conventions

Environment-aware naming was also reinforced.

Resources are tagged using both the environment name and server name:

Examples:

* `dev-web1`
* `prod-web1`

Using consistent naming conventions makes it significantly easier to identify resources within the AWS Management Console and simplifies troubleshooting in larger environments.

---

## Why Multiple Environments Matter

Most organizations maintain multiple deployment environments throughout the software development lifecycle.

Typical examples include:

* Development
* Testing
* Staging
* Production

Each environment exists for a different purpose and often has different infrastructure requirements.

By separating configuration from infrastructure code, organizations can deploy consistent infrastructure while still customizing each environment as needed.

---

## Cost Awareness

Today's lesson also introduced the concept of environment sizing.

Development environments generally prioritize low cost and fast iteration.

Production environments often require:

* Larger instance types
* Additional redundancy
* Higher availability

Designing infrastructure with environment-specific sizing helps balance operational requirements with cloud costs.

---

## Relationship to Terraform Modules

Yesterday's lesson introduced reusable Terraform modules.

Today's lesson demonstrated how those modules become even more valuable when combined with environment-specific configuration.

Rather than creating separate Terraform projects for Development and Production, the same modules can be reused while simply changing the values passed into them.

This reduces duplicated code and makes infrastructure easier to maintain over time.

---

## Key Concepts Learned

* Infrastructure code should remain consistent across environments.
* Configuration values should be separated into environment-specific variable files.
* Terraform can deploy multiple environments using the same codebase.
* Consistent naming conventions improve resource management.
* Environment-specific sizing supports both operational requirements and cost optimization.
* Terraform modules and variable files work together to create reusable, scalable Infrastructure as Code.

---

## Takeaways

Today's lesson marked another important step toward designing Infrastructure as Code for real-world use.

Rather than maintaining separate Terraform projects for each deployment environment, the project now follows a scalable structure where infrastructure is defined once and configured through environment-specific variables.

This approach reduces duplication, simplifies maintenance, and prepares the project for future enhancements such as environment-aware CI/CD pipelines, deployment approvals, and automated promotion from Development to Production.

By separating infrastructure logic from deployment configuration, the Terraform project now more closely resembles the workflows used by professional DevOps teams managing infrastructure across multiple environments.
