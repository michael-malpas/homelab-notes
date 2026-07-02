# Day 21 - Expanding Infrastructure as Code Validation with GitHub Actions

## Objective

Expand the GitHub Actions CI pipeline to automatically validate multiple Infrastructure as Code (IaC) technologies by adding Ansible syntax checking and YAML linting alongside existing Terraform validation.

---

# What I Learned

## What is Infrastructure as Code (IaC)?

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure using configuration files instead of manual changes.

Rather than configuring servers through a graphical interface, infrastructure is defined in code that can be version controlled, reviewed, tested, and automated.

Examples of IaC tools include:

* Terraform
* Ansible
* CloudFormation
* Kubernetes manifests
* Docker Compose

---

# Why Validate More Than Terraform?

Modern infrastructure projects often contain multiple configuration languages.

For example:

* Terraform provisions cloud infrastructure.
* Ansible configures operating systems and applications.
* GitHub Actions automates CI/CD workflows.
* Docker Compose defines container environments.

Each of these files can contain syntax errors that prevent automation from running successfully.

By validating all Infrastructure as Code before merging changes, problems are detected early and are easier to fix.

---

# Expanding the CI Pipeline

The GitHub Actions pipeline now validates multiple components of the repository.

Current pipeline:

```text
Developer
      │
      ▼
git push
      │
      ▼
GitHub Actions
      │
      ├── Terraform Format Check
      ├── Terraform Validation
      ├── Ansible Syntax Check
      └── YAML Validation
```

Each validation step focuses on a different aspect of the repository, providing more comprehensive automated testing.

---

# Separate Workflow Files

Instead of combining every validation into a single workflow, each validation was placed into its own workflow file.

Current workflow structure:

```text
.github/
└── workflows/
    ├── terraform.yml
    ├── ansible.yml
    └── yaml-lint.yml
```

Separating workflows provides several advantages:

* Easier to maintain
* Easier to troubleshoot
* Clear separation of responsibilities
* Simpler to expand as additional automation is added

This follows a common DevOps practice of keeping workflows focused on a single purpose.

---

# Ansible Syntax Validation

GitHub Actions now validates Ansible playbooks automatically using:

```bash
ansible-playbook ansible-demo/playbook.yml --syntax-check
```

The `--syntax-check` option verifies that:

* YAML syntax is valid
* Playbook structure is correct
* Required Ansible keywords are present

No tasks are executed during the syntax check.

This allows playbooks to be tested safely during CI.

---

# YAML Validation with yamllint

Many DevOps tools rely on YAML, including:

* GitHub Actions
* Ansible
* Docker Compose
* Kubernetes

The pipeline now uses `yamllint` to automatically validate YAML files throughout the repository.

Example command:

```bash
yamllint .
```

YAML linting helps detect:

* Incorrect indentation
* Invalid syntax
* Spacing issues
* Formatting inconsistencies

---

# Customizing `.yamllint`

During the lab, a custom `.yamllint` configuration file was created to better support the repository while still enforcing good YAML practices.

The configuration was customized to:

* Disable the requirement for every YAML document to begin with `---`.
* Allow GitHub Actions to use the `on:` keyword without it being incorrectly flagged as a boolean value.
* Continue checking for other invalid truthy values where appropriate.
* Ignore generated directories such as `.terraform/` so downloaded provider files are not linted.
* Continue validating indentation, spacing, syntax, and overall YAML quality.

Customizing the linter reduced unnecessary warnings while preserving meaningful validation.

---

# Reading CI Logs

Every GitHub Actions workflow produces detailed logs for each step.

Learning to read these logs is an important DevOps skill because they provide information such as:

* Commands that were executed
* Validation output
* Errors
* Line numbers
* Exit codes

Rather than guessing why a workflow failed, the logs can be used to identify the exact problem.

---

# Testing the Pipeline

To better understand how CI reports failures, I intentionally introduced errors into the repository.

Examples included:

* Breaking an Ansible playbook
* Creating YAML formatting errors

GitHub Actions detected the problems automatically and reported detailed error messages.

After correcting the files and pushing the changes, the pipeline completed successfully.

This demonstrated how automated validation prevents configuration errors from progressing further in the deployment process.

---

# Commands Used

Check Ansible syntax:

```bash
ansible-playbook ansible-demo/playbook.yml --syntax-check
```

Run YAML linting locally:

```bash
yamllint .
```

Commit changes:

```bash
git add .

git commit -m "Expand CI pipeline with Ansible and YAML validation"

git push
```

---

# Key Takeaways

* Infrastructure as Code includes more than Terraform.
* GitHub Actions can validate multiple technologies within a single repository.
* `ansible-playbook --syntax-check` validates playbooks without executing tasks.
* `yamllint` helps maintain consistent, error-free YAML files.
* A custom `.yamllint` configuration reduces false positives while maintaining useful validation.
* Separating GitHub Actions into dedicated workflow files improves organization and maintainability.
* Reading CI logs is an essential troubleshooting skill for DevOps engineers.

---

# Reflection

Today's lab expanded the Continuous Integration pipeline beyond Terraform to include Ansible and YAML validation, creating a more complete Infrastructure as Code validation process.

By introducing dedicated GitHub Actions workflows for different validation tasks and customizing `yamllint` to better fit the repository, I learned how professional DevOps teams build maintainable CI pipelines that automatically verify multiple technologies. This approach improves code quality, catches errors earlier, and establishes a strong foundation for future automation such as security scanning, testing, and deployment.
