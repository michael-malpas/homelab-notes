# Day 31 Notes – Completing the Migration to GitHub OIDC Authentication

## Overview

Today's lesson completed the migration from legacy AWS access key authentication to modern OpenID Connect (OIDC) authentication for GitHub Actions.

Previously, GitHub Actions authenticated to AWS using long-lived IAM user access keys stored as GitHub Secrets. While functional, this approach required permanent credentials to be managed, rotated, and protected.

The pipeline now authenticates using GitHub's OIDC integration and assumes dedicated IAM roles with temporary credentials issued by AWS Security Token Service (STS). This eliminates the need to store AWS access keys within GitHub and aligns the project with current AWS security recommendations.

Although this homelab uses a single AWS account for simplicity, separate IAM roles are used to simulate Development and Production environments. This models the authentication pattern commonly found in enterprise AWS environments while avoiding the complexity of managing multiple AWS accounts.

---

# Completing the Authentication Migration

The migration was completed by assigning separate IAM roles to each deployment environment:

* **GitHubActions-Development**
* **GitHubActions-Production**

Each role represents an independent deployment identity, allowing Development and Production to authenticate separately even though they currently exist within the same AWS account.

This approach improves security by ensuring each environment has its own permissions and trust relationship.

---

# Development and Production Roles

Instead of sharing a single IAM user, GitHub Actions now assumes different IAM roles depending on the deployment target.

```text
GitHub Actions
        │
        ├──────────────┐
        ▼              ▼
Development Role   Production Role
        │              │
        ▼              ▼
Temporary AWS Credentials
```

Using separate roles allows each environment to evolve independently as additional permissions or security controls are introduced.

In a production organization, these roles would typically exist in separate AWS accounts. For this homelab, using separate IAM roles within one account provides the same learning experience while keeping administration simpler.

---

# Updating the GitHub Actions Workflows

The GitHub Actions workflows were updated to authenticate using the `aws-actions/configure-aws-credentials` action with the `role-to-assume` parameter.

Instead of supplying an Access Key ID and Secret Access Key, GitHub now requests a signed OIDC token, which AWS validates before issuing temporary credentials.

Authentication is now completely handled through IAM roles.

---

# Removing Legacy AWS Credentials

One of the most important milestones in today's lesson was removing the long-lived AWS credentials from GitHub.

The following repository secrets were deleted:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

The only remaining AWS-related secret is:

* `AWS_REGION` (or an equivalent repository variable, depending on configuration)

By removing the access keys entirely, the project now relies exclusively on temporary credentials issued during workflow execution.

This significantly reduces the attack surface and eliminates the need for ongoing access key rotation.

---

# Trust Policies

Today's lesson reinforced the purpose of IAM trust policies.

Unlike permission policies, which define **what** a role is allowed to do, a trust policy defines **who** is allowed to assume the role.

For GitHub Actions, the trust policy evaluates claims contained within the OIDC token, such as:

* GitHub repository
* Repository owner
* Branch
* GitHub Environment
* Audience (`sts.amazonaws.com`)

Only workflows matching the configured conditions are permitted to assume the role.

This prevents unauthorized repositories or workflows from obtaining temporary AWS credentials.

---

# Temporary Credentials

One of the primary benefits of OIDC is the use of temporary credentials.

The authentication process now follows this sequence:

1. GitHub starts a workflow.
2. GitHub requests an OIDC identity token.
3. AWS validates the token using the configured IAM Identity Provider.
4. The IAM trust policy is evaluated.
5. AWS STS issues temporary credentials.
6. Terraform uses those temporary credentials for the duration of the workflow.

Once the workflow completes, the credentials automatically expire.

No permanent AWS credentials are ever exposed to GitHub Actions.

---

# CloudTrail Verification

Authentication was verified by reviewing AWS CloudTrail.

Instead of recording activity performed by an IAM user, CloudTrail now records:

* `AssumeRoleWithWebIdentity`

This confirms that authentication is occurring through OIDC and AWS STS rather than long-lived IAM user credentials.

CloudTrail provides an audit trail showing which IAM role was assumed and when the authentication occurred.

---

# Security Improvements

Completing the OIDC migration significantly strengthened the security posture of the project.

Security improvements now include:

* GitHub OIDC authentication
* Temporary AWS credentials
* Separate Development and Production IAM roles
* GitHub Environment protection
* Manual approval before Production deployment
* Environment-specific Terraform state
* Elimination of stored AWS access keys
* Improved auditability through AWS STS and CloudTrail

Together, these changes closely resemble the authentication model used in modern cloud-native CI/CD pipelines.

---

# IAM Users vs IAM Roles

Today's lesson further emphasized the distinction between IAM users and IAM roles.

## IAM User

Used for:

* Administrative access
* Initial AWS configuration
* Emergency ("break-glass") access

Characteristics:

* Permanent identity
* Long-lived credentials
* Requires credential management

The existing `devops-lab-user` remains available for administrative tasks but is no longer used by GitHub Actions.

---

## IAM Role

Used for:

* CI/CD automation
* Temporary authentication
* Secure workload access

Characteristics:

* No permanent credentials
* Temporary AWS STS tokens
* Assumed only when required
* Preferred for cloud automation

GitHub Actions now authenticates exclusively by assuming IAM roles.

---

# Enterprise Perspective

Although this project currently operates within a single AWS account, the authentication model now mirrors how many organizations structure production deployments.

A typical enterprise architecture would include:

* Separate Development and Production AWS accounts
* Independent IAM roles within each account
* GitHub OIDC authentication
* Separate Terraform state
* Deployment approvals
* Cross-account role assumption

Migrating to multiple AWS accounts in the future would require minimal changes to the CI/CD pipeline because the authentication model has already been designed around IAM roles rather than IAM users.

---

# Key Concepts Learned

* GitHub Actions no longer requires stored AWS access keys.
* OIDC enables secure authentication using temporary credentials.
* IAM roles are the preferred authentication mechanism for automation.
* Trust policies determine who may assume a role.
* Permission policies determine what actions the role may perform.
* AWS STS issues temporary credentials after successful authentication.
* CloudTrail can be used to verify role assumption events.
* Separate deployment identities improve security and prepare projects for enterprise architectures.

---

# Takeaways

Today's lesson completed one of the most significant security improvements made throughout the homelab.

The Terraform CI/CD pipeline now authenticates using GitHub OIDC and IAM roles rather than long-lived AWS access keys, closely matching the authentication model recommended by AWS for modern cloud environments.

Combined with previous work on modular Terraform, remote state management, deployment approvals, environment isolation, and CI/CD automation, the project now demonstrates many of the security and operational practices expected in professional DevOps environments.

The next phase of the roadmap will focus on strengthening the quality and security of the infrastructure itself through least-privilege IAM policies, infrastructure linting, security scanning, and cost optimization before expanding into more advanced AWS networking and Kubernetes topics.
