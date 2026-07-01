# Day 20 - Introduction to Continuous Integration with GitHub Actions

## Objective

Learn the fundamentals of Continuous Integration (CI) by creating a GitHub Actions workflow that automatically validates Terraform code whenever changes are pushed to GitHub.

---

# What I Learned

## What is Continuous Integration (CI)?

Continuous Integration (CI) is the practice of automatically testing and validating code whenever changes are committed to a repository.

Instead of waiting until deployment to discover problems, CI provides immediate feedback by running automated checks after every push or pull request.

Benefits of CI include:

* Detecting errors early
* Reducing manual testing
* Maintaining consistent code quality
* Preventing broken code from reaching production
* Improving collaboration between team members

---

# What is GitHub Actions?

GitHub Actions is GitHub's built-in automation platform.

It allows workflows to run automatically in response to events such as:

* Pushes
* Pull Requests
* Scheduled tasks
* Manual triggers

These workflows execute inside temporary virtual machines called **runners**.

---

# What is a Workflow?

A workflow is a YAML file that defines an automated process.

Workflows are stored in:

```text id="krrw4a"
.github/workflows/
```

Each workflow contains:

* Triggers
* Jobs
* Steps

Example workflow:

```text id="zzrvxy"
Push Code
      ↓
GitHub Action Starts
      ↓
Create Runner
      ↓
Checkout Repository
      ↓
Install Terraform
      ↓
Run Validation
      ↓
Report Success or Failure
```

---

# GitHub Runner

GitHub executes workflows using temporary virtual machines called runners.

Today's workflow used:

```yaml id="0hzkh9"
runs-on: ubuntu-latest
```

Each runner:

* Starts as a clean Ubuntu virtual machine
* Downloads the repository
* Executes the workflow steps
* Is destroyed after completion

This ensures every workflow runs in a consistent environment.

---

# Terraform Validation Pipeline

The workflow performed the following tasks:

1. Checked out the repository.
2. Installed Terraform.
3. Initialized the Terraform project.
4. Validated the Terraform configuration.
5. Checked Terraform formatting (optional improvement).

Workflow file:

```text id="yd8a9s"
.github/workflows/terraform.yml
```

Key workflow steps:

```yaml id="nobpdi"
actions/checkout
hashicorp/setup-terraform
terraform init
terraform validate
terraform fmt -check -recursive
```

---

# Understanding Each Workflow Step

## actions/checkout

Downloads the repository onto the GitHub runner.

Without this step, the runner would have no project files to work with.

---

## hashicorp/setup-terraform

Installs Terraform on the runner.

This is equivalent to manually installing Terraform on a local machine.

---

## terraform init

Initializes the working directory by downloading required providers and preparing Terraform for use.

---

## terraform validate

Checks the Terraform configuration for syntax errors and configuration issues without making any infrastructure changes.

---

## terraform fmt -check

Verifies that Terraform files follow standard formatting.

This helps maintain consistent code style across a team.

---

# terraform validate vs terraform plan

## terraform validate

Checks:

* Syntax
* Required arguments
* Configuration correctness

Does **not** contact AWS or create infrastructure.

Example:

```bash id="4pdd9t"
terraform validate
```

---

## terraform plan

Contacts the cloud provider and compares the Terraform configuration with the current infrastructure state.

Shows what Terraform intends to create, modify, or destroy.

Example:

```bash id="kfj2ls"
terraform plan
```

---

# Intentionally Breaking the Pipeline

To understand how CI reports errors, I intentionally introduced a syntax error into the Terraform configuration.

GitHub Actions automatically failed during the validation step and reported the exact location of the error.

After fixing the configuration and pushing the changes again, the workflow completed successfully.

This demonstrated how CI catches mistakes before infrastructure is deployed.

---

# Why CI Matters

Without CI:

```text id="g6k4ci"
Write Code
     ↓
Deploy
     ↓
Discover Errors
```

With CI:

```text id="ibngh5"
Write Code
     ↓
Push to GitHub
     ↓
Automatic Validation
     ↓
Fix Problems
     ↓
Deploy
```

CI shifts error detection earlier in the development process, reducing the risk of deploying broken code.

---

# Commands Used

Initialize Terraform:

```bash id="n4gchd"
terraform init
```

Validate Terraform:

```bash id="uh8zzj"
terraform validate
```

Check formatting:

```bash id="ux7wnw"
terraform fmt -check -recursive
```

Automatically format Terraform:

```bash id="nr7tmy"
terraform fmt -recursive
```

Commit changes:

```bash id="7jhftr"
git add .

git commit -m "Add GitHub Actions Terraform validation workflow"

git push
```

---

# Key Takeaways

* Continuous Integration automatically validates code after changes are committed.
* GitHub Actions provides built-in CI capabilities directly within GitHub repositories.
* Workflows are defined using YAML files stored in `.github/workflows`.
* GitHub-hosted runners provide clean, temporary environments for executing workflows.
* `terraform validate` checks configuration correctness without modifying infrastructure.
* `terraform fmt -check` enforces consistent formatting across Terraform files.
* Automated validation helps catch problems before infrastructure changes are applied.

---

# Reflection

Today's lab introduced the first stage of Infrastructure as Code automation by integrating Terraform validation into a GitHub Actions workflow.

Instead of manually running validation commands before every commit, GitHub now performs these checks automatically whenever code is pushed. This demonstrated the value of Continuous Integration by providing immediate feedback, improving code quality, and reducing the likelihood of configuration errors reaching production environments.

This lesson also introduced the foundation for future CI/CD pipelines, where validation, testing, security scanning, and infrastructure deployments can all be automated through GitHub Actions.
