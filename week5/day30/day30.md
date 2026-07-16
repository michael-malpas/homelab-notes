# Day 30 Notes – Modern AWS Authentication with GitHub OIDC

## Overview

Today's lesson focused on modernizing the authentication mechanism used by the Terraform CI/CD pipeline.

Until this point, GitHub Actions authenticated to AWS using long-lived IAM user access keys stored as GitHub Secrets. While functional, this approach requires permanent credentials to be stored and managed, increasing the operational overhead of key rotation and the potential impact of credential exposure.

To align the project with current AWS best practices, the authentication model was redesigned to use **OpenID Connect (OIDC)** and **IAM Roles**. Instead of storing AWS credentials in GitHub, workflows now request short-lived credentials by assuming an IAM role through AWS Security Token Service (STS).

Although this homelab continues to use a single AWS account for simplicity, separate IAM roles are used to simulate Development and Production environments. This mirrors the authentication model commonly used in multi-account AWS organizations while keeping the lab easier to manage.

---

## Previous Authentication Model

The original pipeline authenticated using an IAM user's access keys stored as GitHub repository secrets.

```text
GitHub Actions
        │
        ▼
GitHub Secrets
(AWS Access Key ID
 & Secret Access Key)
        │
        ▼
AWS IAM User
        │
        ▼
Terraform
```

While this approach works, it has several disadvantages:

* Long-lived credentials must be created and stored.
* Access keys require periodic rotation.
* Secrets can be accidentally exposed.
* Compromised credentials remain valid until revoked.
* Managing credentials becomes increasingly difficult as environments grow.

---

## New Authentication Model

The pipeline now uses GitHub's built-in OpenID Connect integration.

```text
GitHub Actions
        │
        ▼
OIDC Token
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
Temporary Credentials
        │
        ▼
Terraform
```

No permanent AWS credentials are stored within GitHub.

Each workflow receives temporary credentials only after AWS validates the identity of the workflow and authorizes it to assume the appropriate IAM role.

---

## OpenID Connect (OIDC)

OpenID Connect is an identity protocol that allows GitHub Actions to prove its identity to AWS.

When a workflow begins:

1. GitHub issues a signed identity token.
2. AWS validates the token using the configured IAM Identity Provider.
3. AWS evaluates the IAM role's trust policy.
4. If the request is authorized, AWS Security Token Service (STS) issues temporary credentials.
5. Terraform uses those temporary credentials to interact with AWS.

The workflow never handles or stores long-lived AWS access keys.

---

## IAM Users vs. IAM Roles

One of the most important concepts introduced today was the distinction between IAM users and IAM roles.

### IAM User

An IAM user represents a permanent identity within an AWS account.

Characteristics include:

* Long-lived credentials.
* Access keys.
* Passwords (optional).
* Requires credential management.
* Suitable for administrators or human users.

The existing `devops-lab-user` will remain as the administrative account used for initial AWS configuration and emergency ("break-glass") access.

It is no longer intended to authenticate GitHub Actions.

---

### IAM Role

An IAM role represents a temporary identity that can be assumed by trusted entities.

Characteristics include:

* No permanent credentials.
* Temporary security tokens.
* Assumed only when required.
* Easier to audit and secure.
* Preferred for automation.

GitHub Actions now authenticates by assuming IAM roles rather than logging in as an IAM user.

---

## Simulating Multiple AWS Accounts

Enterprise environments typically separate Development and Production into different AWS accounts.

For this homelab, separate IAM roles are used within a single AWS account to simulate that architecture.

```text
GitHub Actions
        │
        ├──────────────┐
        ▼              ▼
Development Role   Production Role
```

Although both roles exist within the same AWS account, each represents a separate deployment environment with independent permissions and trust relationships.

This approach keeps the lab manageable while still demonstrating enterprise design principles.

---

## IAM Identity Provider

AWS does not inherently trust GitHub.

An IAM Identity Provider establishes that trust relationship.

The provider created during today's lesson allows AWS to verify identity tokens issued by GitHub.

Only after the token is successfully validated can AWS evaluate whether the requested IAM role may be assumed.

The Identity Provider performs authentication, while the IAM role controls authorization.

---

## Trust Policies

Unlike standard IAM permission policies, a trust policy answers a different question:

**Who is allowed to assume this role?**

The trust policy is configured to allow only approved GitHub workflows to request temporary credentials.

Typical conditions include:

* GitHub repository.
* Repository owner.
* Branch or environment.
* Audience (`sts.amazonaws.com`).

Restricting trust policies reduces the risk of unauthorized workflows assuming privileged roles.

---

## Least Privilege

Another important security principle introduced today was **least privilege**.

Rather than granting broad administrative permissions, IAM roles should receive only the permissions necessary to perform their required tasks.

For Terraform this generally includes permissions to manage:

* EC2
* Security Groups
* S3 (Terraform backend)
* Additional AWS services as infrastructure expands

As the homelab grows, permissions should continue to be refined to eliminate unnecessary access.

---

## Security Improvements

Migrating to OIDC provides several advantages over access keys.

### Before

* Permanent credentials.
* Manual key rotation.
* Secrets stored in GitHub.
* Greater exposure if credentials are leaked.

### After

* Temporary credentials.
* No stored AWS access keys.
* Authentication based on trusted identity.
* Reduced operational overhead.
* Improved auditability through AWS STS and CloudTrail.

This authentication model is now considered the AWS best practice for CI/CD pipelines.

---

## Enterprise Perspective

Although this project uses one AWS account, the authentication model closely resembles enterprise deployments.

A production implementation would commonly include:

* Separate AWS Development and Production accounts.
* Independent IAM roles within each account.
* GitHub OIDC authentication.
* Separate Terraform state.
* Deployment approval before Production.
* Cross-account role assumption.

Using separate IAM roles today prepares the project for a future migration to multiple AWS accounts with minimal changes to the deployment workflow.

---

## Key Concepts Learned

* Long-lived AWS access keys are no longer considered the preferred authentication method for CI/CD pipelines.
* GitHub OIDC enables secure authentication without storing AWS credentials.
* IAM roles are preferred over IAM users for automation.
* Temporary credentials reduce the security risks associated with permanent access keys.
* IAM Identity Providers authenticate external identity systems such as GitHub.
* Trust policies determine which workflows may assume an IAM role.
* Permission policies determine what actions the assumed role may perform.
* Least privilege should guide the design of all IAM roles.

---

## Takeaways

Today's lesson significantly improved the security posture of the Terraform project.

The CI/CD pipeline is transitioning from static credentials to temporary role-based authentication, closely matching the authentication model recommended by AWS for modern Infrastructure as Code workflows.

Combined with previous work on modular Terraform design, environment-specific configuration, deployment promotion, and isolated Terraform state, the project now reflects many of the operational and security practices expected in professional DevOps environments.

Future lessons will complete the migration by configuring the Production deployment role, removing legacy access keys from GitHub, and further refining IAM permissions according to the principle of least privilege.
