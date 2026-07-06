# Day 22 - Securing GitHub Actions with GitHub Secrets

## Objective

Learn how to securely store sensitive credentials in GitHub and use them within GitHub Actions workflows to authenticate with AWS without exposing secrets in the repository.

---

# What I Learned

## Why Secrets Should Never Be Stored in Git

Infrastructure automation often requires credentials such as:

* AWS Access Keys
* API Tokens
* Passwords
* SSH Keys

These credentials should never be committed to a Git repository.

If secrets are accidentally pushed to GitHub, they become part of the repository's history and may be exposed to anyone with access. Even if deleted later, they can often still be recovered from previous commits.

Instead, sensitive information should be stored using a secure secrets management solution.

---

# What are GitHub Secrets?

GitHub Secrets provide encrypted storage for sensitive values used by GitHub Actions workflows.

Secrets are encrypted by GitHub and can be referenced during workflow execution without exposing their values.

Example:

```yaml id="l1a5br"
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
```

The workflow receives the value at runtime while the actual secret remains hidden.

---

# Repository Secrets

For this project, repository-level secrets were created.

Configured secrets:

| Secret Name             | Purpose                                |
| ----------------------- | -------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | AWS access key used for authentication |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key                  |
| `AWS_REGION`            | Default AWS region (`us-east-1`)       |

These secrets are available only to workflows running within this repository.

---

# Types of GitHub Secrets

GitHub supports several levels of secrets.

## Repository Secrets

Available only within a single repository.

Best for:

* Personal projects
* Small repositories
* Individual applications

---

## Environment Secrets

Available only when deploying to specific environments such as:

* Development
* Staging
* Production

Useful when different environments require different credentials.

---

## Organization Secrets

Shared across multiple repositories within a GitHub organization.

Useful for large teams that maintain many repositories using the same credentials.

---

# Using Secrets in a Workflow

Secrets are injected into a workflow using environment variables.

Example:

```yaml id="1v4xpa"
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  AWS_REGION: ${{ secrets.AWS_REGION }}
```

These values become available only while the workflow is running.

---

# Verifying Secrets

A test workflow was created to verify that the required secrets were available.

The workflow checked that each environment variable existed before continuing.

Example logic:

```text id="pt3d4q"
If secret exists
      ↓
Display success message

Else
      ↓
Fail the workflow
```

This confirmed that GitHub Secrets were being injected correctly without exposing their values.

---

# Authenticating with AWS

The workflow used the official AWS GitHub Action to configure credentials.

```yaml id="6mr4z6"
uses: aws-actions/configure-aws-credentials@v4
```

This action:

* Retrieves credentials from GitHub Secrets
* Configures the AWS CLI on the GitHub runner
* Authenticates future AWS CLI commands

Once configured, any AWS CLI command can authenticate without manually running `aws configure`.

---

# Verifying AWS Authentication

Authentication was verified using:

```bash id="n5obeh"
aws sts get-caller-identity
```

Successful output displays:

* AWS Account ID
* IAM User ARN
* User ID

This confirms the GitHub runner successfully authenticated with AWS.

---

# Testing AWS Access

After authentication, the workflow listed available S3 buckets using:

```bash id="nd79k7"
aws s3 ls
```

This verified that:

* AWS authentication succeeded
* The IAM user had permission to access Amazon S3

---

# Debugging the Workflow

During development, the workflow failed because of a typo in the GitHub Action reference.

Incorrect:

```yaml id="fxnghu"
uses: aws-actions/configure-aws-credentals@v4
```

Correct:

```yaml id="jlwm9k"
uses: aws-actions/configure-aws-credentials@v4
```

GitHub reported:

```text id="ubj38l"
Unable to resolve action...
repository not found
```

This highlighted the importance of carefully reviewing workflow definitions and reading CI logs when troubleshooting.

---

# AWS Authentication Methods

AWS now recommends using temporary credentials whenever possible.

Common authentication methods include:
```
| Method                 | Typical Use                             |
| ---------------------- | --------------------------------------- |
| IAM Role               | EC2, Lambda, ECS, EKS                   |
| IAM User + Access Keys | Local development and legacy automation |
| GitHub OIDC            | Modern GitHub Actions authentication    |
```
For this lab, IAM access keys were used because they demonstrate how GitHub Secrets work and provide a foundation for understanding CI/CD authentication.

In future labs, this workflow can be updated to use GitHub's OpenID Connect (OIDC) integration, which eliminates the need for long-lived AWS access keys.

---

# Security Best Practices

When working with GitHub Actions and AWS:

* Never commit credentials to Git.
* Store secrets using GitHub Secrets.
* Use separate IAM users for automation.
* Grant only the permissions required (Principle of Least Privilege).
* Rotate access keys regularly.
* Remove unused credentials.
* Review IAM permissions periodically.

---

# Commands Used

Verify AWS identity:

```bash id="vx4m93"
aws sts get-caller-identity
```

List S3 buckets:

```bash id="b7p5ey"
aws s3 ls
```

Commit changes:

```bash id="wlrjlwm"
git add .

git commit -m "Add GitHub Secrets workflow"

git push
```

---

# Key Takeaways

* GitHub Secrets provide secure storage for sensitive information used by GitHub Actions.
* Secrets are injected into workflows as environment variables and are not exposed in logs.
* The `aws-actions/configure-aws-credentials` action configures AWS authentication for GitHub runners.
* `aws sts get-caller-identity` is a useful command for verifying AWS authentication.
* GitHub Actions workflows can securely interact with AWS services without hardcoding credentials.
* Reading workflow logs is an essential troubleshooting skill.
* AWS recommends temporary credentials (such as IAM Roles and OIDC) over long-lived access keys whenever possible.

---

# Reflection

Today's lab focused on one of the most important aspects of DevOps: securely managing credentials in automated workflows. I learned how GitHub Secrets protect sensitive information, how GitHub Actions can authenticate with AWS using those secrets, and how to verify that authentication with the AWS CLI. I also gained experience troubleshooting workflow errors by reading GitHub Actions logs and identifying issues such as incorrect action names. While this project used IAM access keys for learning purposes, I also learned that modern production environments increasingly use OpenID Connect (OIDC) and temporary credentials to improve security. This lesson established the foundation for securely integrating cloud services into CI/CD pipelines.
