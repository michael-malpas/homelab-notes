# Day 35 – Production IAM, Least Privilege & IAM Access Analyzer

## Overview

Today's lesson focused on completing the security model for the Terraform CI/CD platform. The goal was to move beyond simply authenticating to AWS and begin designing a more secure authorization model using separate IAM roles, customer-managed policies, and the principle of least privilege.

The project now more closely resembles an enterprise deployment pipeline by separating Development and Production identities while using GitHub OpenID Connect (OIDC) authentication and temporary AWS credentials.

---

# Why Least Privilege Matters

One of the core principles of cloud security is **Least Privilege**.

Rather than granting broad administrative access, every identity should receive only the permissions required to perform its specific task.

This reduces the potential impact of compromised credentials, limits accidental changes, and makes cloud environments easier to audit and maintain.

Instead of asking:

> "What permissions should I grant?"

A better question is:

> "What is the minimum set of permissions required for this workload?"

This mindset is fundamental to modern cloud security.

---

# IAM Roles vs IAM Policies

Today's lesson reinforced the distinction between IAM roles and IAM policies.

An **IAM Role** represents an identity that can be assumed by a trusted entity.

An **IAM Policy** defines what that identity is allowed to do.

Separating identity from permissions makes access easier to manage and allows permissions to evolve independently as infrastructure grows.

---

# Development and Production Roles

The project now uses separate IAM roles for Development and Production deployments.

Each GitHub Environment assumes its corresponding AWS role through GitHub OIDC authentication.

This mirrors the authentication strategy commonly used in enterprise AWS environments, where separate accounts or roles isolate workloads between environments.

Although the homelab uses a single AWS account for simplicity, using dedicated IAM roles provides many of the same operational and security benefits.

---

# Customer-Managed IAM Policies

Instead of attaching broad AWS-managed policies such as AdministratorAccess, the project now uses customer-managed IAM policies.

This provides several advantages:

* Greater visibility into granted permissions
* Easier auditing
* Version control of policy changes
* The ability to remove unnecessary permissions over time

Customer-managed policies also encourage intentional permission design rather than relying on overly permissive defaults.

---

# GitHub OIDC Authentication Review

The GitHub Actions workflow authenticates using OpenID Connect (OIDC).

The authentication process now follows this sequence:

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
Temporary Credentials
        │
        ▼
Terraform
```

Using temporary credentials removes the need to store long-lived AWS access keys inside GitHub and aligns the project with current AWS security best practices.

---

# IAM Access Analyzer

Today's lesson introduced **IAM Access Analyzer**.

Access Analyzer evaluates IAM policies and provides recommendations to improve security by identifying:

* Overly broad permissions
* Unused permissions
* Wildcard resource access
* Opportunities to better follow AWS best practices

Rather than writing a perfect IAM policy on the first attempt, policies should be refined over time based on actual infrastructure requirements and analyzer feedback.

This reflects how production IAM policies are typically maintained.

---

# Security Improvements

Several important security enhancements have now been incorporated into the project:

* GitHub OpenID Connect authentication
* Temporary AWS STS credentials
* Separate Development and Production IAM roles
* Customer-managed IAM policies
* Principle of least privilege
* IAM Access Analyzer policy validation
* Manual Production deployment approvals
* Remote Terraform state stored securely in Amazon S3

Together, these improvements significantly strengthen the overall security posture of the CI/CD pipeline.

---

# Updating the Project Documentation

The project README was updated to reflect the completed authentication and authorization model.

New documentation now includes:

* GitHub OIDC authentication
* Development and Production IAM roles
* Customer-managed IAM policies
* Least privilege design principles
* IAM Access Analyzer
* Updated project architecture
* Expanded security documentation

Maintaining accurate documentation is an important part of infrastructure engineering and helps demonstrate design decisions to collaborators, reviewers, and prospective employers.

---

# Key Concepts Learned

* IAM roles define identities, while IAM policies define permissions.
* Least privilege reduces security risk by granting only the permissions required.
* Customer-managed policies provide greater flexibility and control than broad AWS-managed policies.
* GitHub OIDC authentication eliminates the need for long-lived AWS credentials.
* Temporary credentials issued by AWS STS improve overall security.
* IAM Access Analyzer helps identify opportunities to further tighten IAM permissions.
* Development and Production environments should use separate identities even when sharing infrastructure code.

---

# Why This Matters for DevOps

Modern DevOps engineers are expected to understand not only infrastructure automation but also secure identity management.

Automating deployments without considering authentication and authorization introduces unnecessary risk.

By implementing GitHub OIDC, environment-specific IAM roles, least-privilege permissions, and policy validation, the project now reflects authentication and authorization practices commonly found in production cloud environments.

---

# Reflection

Today's lesson completed another major milestone in the evolution of the homelab.

The project has progressed from simply provisioning AWS resources to implementing a secure, production-inspired deployment platform.

Security is no longer an afterthought—it has become an integral part of the infrastructure design.

This reinforces an important DevOps principle:

> Secure automation is better than automated insecurity. Building reliable infrastructure means carefully controlling who can deploy, what they can change, and ensuring those permissions remain as minimal as possible.
