# Terraform CI Demo

## Project Overview

This project demonstrates how to use GitHub Actions to automatically validate Terraform code whenever changes are pushed to GitHub. It serves as an introduction to Continuous Integration (CI) by automating common Terraform validation tasks before infrastructure is deployed.

The goal of this project is to ensure that Terraform configurations are properly formatted, initialized, and syntactically correct before being merged into the main branch.

---

## Technologies Used

* Terraform
* Git
* GitHub
* GitHub Actions
* YAML

---

## Project Structure

```text
terraform-ci-demo/
├── main.tf
└── README.md

.github/
└── workflows/
    └── terraform.yml
```

---

## GitHub Actions Workflow

The workflow is triggered automatically when code is pushed to the configured branches or when a pull request is opened.

The pipeline performs the following tasks:

1. Checks out the repository.
2. Installs Terraform.
3. Initializes the Terraform working directory.
4. Verifies Terraform formatting.
5. Validates the Terraform configuration.


This provides immediate feedback if invalid Terraform code is committed.

---

## Workflow File

```text
.github/workflows/terraform.yml
```

Key workflow steps include:

```yaml
actions/checkout
hashicorp/setup-terraform
terraform init
terraform validate
terraform fmt -check -recursive
```

---

## Running Locally

Initialize Terraform:

```bash
terraform init
```
Check formatting:

```bash
terraform fmt -check -recursive
```

Validate the configuration:

```bash
terraform validate
```



---

## CI/CD Benefits

Using GitHub Actions provides several advantages:

* Automatically validates Terraform code
* Detects syntax errors before deployment
* Enforces consistent formatting
* Creates repeatable validation for every commit
* Reduces the chance of broken infrastructure changes reaching production

---

## Example Workflow

```text
Developer
    │
    ▼
git push
    │
    ▼
GitHub Actions
    │
    ▼
Checkout Repository
    │
    ▼
Terraform Init
    │
    ▼
Terraform Validate
    │
    ▼
Terraform Format Check
    │
    ▼
Pass or Fail
```

---

## Lessons Learned

Through this project I learned:

* How GitHub Actions workflows are structured
* How GitHub-hosted runners execute automation tasks
* How to automate Terraform validation
* The difference between local validation and CI validation
* How Continuous Integration improves infrastructure quality by identifying issues before deployment

---

## Future Improvements

Planned enhancements include:

* Add Terraform linting with TFLint
* Run security scans with Checkov or tfsec
* Generate Terraform plans automatically on pull requests
* Store Terraform state remotely using Amazon S3
* Integrate Ansible syntax validation into the pipeline
* Add automated infrastructure deployment after successful validation

---

## Author

Michael Malpas

DevOps Homelab Project

