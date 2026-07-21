# DevOps Training Notes - Terraform CI/CD Quality Gates and Infrastructure Security

## Lesson Overview

Today's lesson focused on improving the Terraform CI/CD pipeline by adding automated infrastructure quality gates.

The goal was to move the Terraform workflow closer to an enterprise Infrastructure as Code process where infrastructure changes are automatically validated, scanned, and reviewed before deployment.

The pipeline was updated to ensure that Terraform plans are only generated after all required validation and security checks pass.

---

# Infrastructure Quality Gates

A quality gate is an automated checkpoint that infrastructure changes must pass before continuing through the deployment process.

The updated Terraform workflow follows this process:

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
Code Review
          │
          ▼
terraform apply
```

This prevents invalid, poorly formatted, or insecure Terraform configurations from reaching deployment stages.

---

# Terraform fmt

## Purpose

`terraform fmt` ensures Terraform configuration files follow the standard HashiCorp formatting conventions.

Example:

```bash
terraform fmt -check -recursive
```

The `-check` option verifies formatting without modifying files.

The `-recursive` option checks Terraform files within subdirectories.

## Benefits

- Maintains consistent Terraform formatting
- Improves readability
- Reduces unnecessary formatting changes during reviews
- Enforces Terraform coding standards

---

# Terraform Validate

## Purpose

`terraform validate` checks whether Terraform configuration is syntactically valid and internally consistent.

Example:

```bash
terraform init
terraform validate
```

## What It Checks

- Terraform syntax
- Provider configuration
- Resource definitions
- Module references
- Variable usage

## Important Note

`terraform validate` requires Terraform initialization first because Terraform needs to download provider and module information.

However, it does not require access to the actual AWS infrastructure.

---

# TFLint

## Purpose

TFLint provides Terraform static analysis beyond Terraform's built-in validation.

It identifies potential issues before infrastructure deployment.

Example:

```bash
tflint
```

## Checks Include

- Terraform best practices
- Deprecated configurations
- Provider-specific issues
- AWS resource recommendations
- Potential configuration mistakes

## AWS Ruleset

TFLint can use provider-specific plugins.

Example:

```hcl
plugin "aws" {
  enabled = true
  version = "0.38.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
```

This allows AWS-specific Terraform recommendations to be checked automatically.

---

# Checkov

## Purpose

Checkov performs Infrastructure as Code security scanning.

It analyzes Terraform files against security policies and best practices.

Example:

```bash
checkov -d .
```

## Security Checks Include

- Publicly accessible resources
- Security group exposure
- Encryption requirements
- IAM security issues
- Cloud security best practices

---

# Checkov Suppressions

Some security checks may intentionally fail in a lab environment.

Example:

```hcl
#checkov:skip=CKV_AWS_382:EC2 instances require outbound internet access for package updates
resource "aws_security_group" "web" {
```

Important:

The suppression comment must be placed inside the Terraform resource block.

Incorrect:

```hcl
#checkov:skip=CKV_AWS_382
resource "aws_security_group" "web" {
}
```

Correct:

```hcl
resource "aws_security_group" "web" {

  #checkov:skip=CKV_AWS_382:EC2 instances require outbound internet access for package updates

}
```

Suppressions should only be used when the configuration is intentionally designed that way and the reason is documented.

---

# GitHub Actions Workflow Design

The Terraform pull request workflow was updated to represent a real CI validation pipeline.

Workflow:

```text
Pull Request
      │
      ▼
terraform-pr.yml
      │
      ├── Terraform fmt
      │
      ├── Terraform validate
      │
      ├── TFLint
      │
      ├── Checkov
      │
      └── Terraform plan
```

The Terraform plan stage should only execute after the previous quality checks succeed.

This prevents reviewing plans generated from invalid or insecure infrastructure code.

---

# Documentation Updates

The Terraform CI/CD project README was updated to document:

- Terraform quality gates
- Security scanning
- TFLint usage
- Checkov usage
- Updated workflow naming (`terraform-pr.yml`)
- Updated CI/CD pipeline flow

The README now better represents the project as an enterprise-inspired Infrastructure as Code workflow.

---

# Key Takeaways

## Infrastructure Should Be Tested Like Application Code

Terraform is code and should follow similar development practices:

- Version control
- Automated validation
- Security scanning
- Code review
- Controlled deployment

---

## Plan Should Not Be the First Validation Step

A Terraform plan should only happen after:

1. Formatting checks
2. Configuration validation
3. Static analysis
4. Security scanning

This reduces the chance of discovering problems late in the deployment process.

---

## Security Should Shift Left

Security checks should happen during development rather than after deployment.

Tools like Checkov allow security issues to be identified before infrastructure reaches AWS.

---

## Current CI/CD Pipeline Progress

The project now includes:

✅ Terraform formatting  
✅ Terraform validation  
✅ Terraform linting  
✅ Infrastructure security scanning  
✅ Terraform planning  
✅ Pull request review  
✅ GitHub OIDC authentication  
✅ IAM role-based deployments  
✅ Production approval gates  

---

# Next Steps

Continue expanding the security portion of the DevOps roadmap before moving into containerization.

Future security topics:

- Least privilege IAM refinement
- AWS security best practices
- Terraform security testing
- Secrets management
- Additional infrastructure scanning tools
- Cost/security monitoring

