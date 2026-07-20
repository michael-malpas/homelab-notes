# Terraform Least Privilege IAM Policy - Phase 1

## Overview

Today I worked on creating a least privilege IAM policy for Terraform instead of using broad administrator permissions.

The goal was to allow Terraform to manage the resources required by the project while only granting the minimum AWS permissions needed.

The workflow used:

1. Start with read-only permissions
2. Run Terraform commands
3. Observe AWS `AccessDenied` errors
4. Add only the required permission
5. Repeat until Terraform succeeds

This follows the principle of least privilege:

> Grant only the permissions required for the workload to function.

---

# Terraform Backend IAM Permissions

Terraform is using an S3 backend:

```hcl
bucket = "michael-malpas-terraform-state-2026"
key    = "development/terraform.tfstate"
region = "us-east-1"
use_lockfile = true
```

Required permissions:

## Bucket-level permissions

```json
"s3:ListBucket",
"s3:GetBucketLocation"
```

Resource:

```
arn:aws:s3:::michael-malpas-terraform-state-2026
```

These allow Terraform to:

* locate the state bucket
* verify the bucket region
* list objects

---

## State object permissions

```json
"s3:GetObject",
"s3:PutObject",
"s3:DeleteObject"
```

Resources:

```
arn:aws:s3:::michael-malpas-terraform-state-2026/development/terraform.tfstate

arn:aws:s3:::michael-malpas-terraform-state-2026/development/terraform.tfstate.tflock
```

These allow Terraform to:

* read the state file
* update state after changes
* create/remove the Terraform lock file

---

# Initial Terraform Permissions

The first working policy included:

## EC2 Read

```json
"ec2:Describe*"
```

Terraform plans require read access because Terraform compares:

```
Desired Terraform Configuration
            |
            v
Current AWS Infrastructure
```

`terraform plan` does not require create permissions.

---

## STS Identity Check

```json
"sts:GetCallerIdentity"
```

Used to verify which AWS identity Terraform is running as.

Command:

```bash
aws sts get-caller-identity
```

---

# Adding EC2 Write Permissions

After adding:

```json
"ec2:RunInstances"
```

Terraform was able to begin creating EC2 instances.

However, the apply failed with:

```
not authorized to perform: ec2:CreateTags
```

## Why?

EC2 creation and tagging are separate AWS API operations.

Terraform performs:

```
RunInstances
        |
        v
CreateTags
```

Both require separate IAM permissions.

Added:

```json
"ec2:CreateTags"
```

After adding this permission:

```bash
terraform apply
```

completed successfully.

---

# Final EC2 Permissions Added

Current EC2 lifecycle permissions:

```json
[
  "ec2:RunInstances",
  "ec2:StartInstances",
  "ec2:StopInstances",
  "ec2:TerminateInstances",
  "ec2:CreateTags"
]
```

Security group permissions:

```json
[
  "ec2:CreateSecurityGroup",
  "ec2:DeleteSecurityGroup",
  "ec2:AuthorizeSecurityGroupIngress",
  "ec2:AuthorizeSecurityGroupEgress",
  "ec2:RevokeSecurityGroupIngress",
  "ec2:RevokeSecurityGroupEgress"
]
```

---

# Terraform Apply Validation

Terraform successfully applied using:

```
arn:aws:sts::505402162699:assumed-role/GitHubActions-Dev/GitHubActions
```

This confirmed:

* GitHub Actions OIDC authentication is working
* Terraform is using the expected IAM role
* The IAM policy is attached to the correct identity
* No static AWS access keys are being used by GitHub Actions

---

# IAM Policy Organization Improvements

Initial policy organization was based on individual actions:

Example:

```
EC2CreateInstances
EC2StartStopInstances
EC2DeleteInstances
```

Improved organization groups permissions by capability:

```
Terraform Backend Access

STS Identity Access

EC2 Read

EC2 Instance Lifecycle

EC2 Security Group Management
```

This makes policies easier to audit and maintain.

