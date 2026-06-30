# Day 19 - Multi-Environment Terraform & Remote State

## Objective

Learn how professional teams organize Terraform projects using multiple environments, variable files, remote state storage, and state locking.

---

# What I Learned

## Using Multiple Environments

Instead of maintaining separate Terraform projects for Development and Production, a single Terraform configuration can be reused with different variable files.

Example:

```text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── dev.tfvars
└── prod.tfvars
```

The infrastructure code remains the same while the variables define the differences between environments.

### Development

* Smaller EC2 instance
* Lower cost
* Used for testing

### Production

* Larger EC2 instance
* Higher performance
* Used for live workloads

Deployment is controlled with:

```bash
terraform apply -var-file=dev.tfvars
```

or

```bash
terraform apply -var-file=prod.tfvars
```

This makes Terraform projects reusable and easier to maintain.

---

# Terraform Variables

Variables were defined inside `variables.tf`:

```text
aws_region
instance_type
key_name
my_ip
environment
```

Values were stored separately inside `.tfvars` files.

Example:

```hcl
environment = "dev"
```

or

```hcl
environment = "prod"
```

Keeping values separate from the infrastructure code makes it easier to deploy multiple environments without modifying the Terraform configuration.

---

# Resource Tagging

Resources were tagged using variables:

```hcl
tags = {
  Name        = "${var.environment}-webserver"
  Environment = var.environment
  ManagedBy   = "Terraform"
}
```

Examples:

Development:

```text
dev-webserver
```

Production:

```text
prod-webserver
```

Proper tagging helps organize AWS resources, simplifies cost tracking, and improves automation.

---

# Terraform State

Terraform stores information about managed infrastructure inside:

```text
terraform.tfstate
```

The state file keeps track of:

* Resources Terraform created
* Resource IDs
* Current configuration
* Infrastructure metadata

Terraform compares the configuration files against the state file to determine what changes need to be made.

Without the state file, Terraform cannot accurately determine what infrastructure already exists.

---

# Why Local State Is a Problem

A local state file works for a single user but becomes problematic when multiple engineers collaborate.

Example:

Engineer A:

```text
terraform.tfstate
```

Engineer B:

```text
terraform.tfstate
```

If both engineers make changes independently, their state files can become inconsistent, potentially leading to infrastructure conflicts.

This is why production environments use remote state.

---

# Remote State with Amazon S3

Instead of storing the state locally, Terraform can store it in an Amazon S3 bucket.

Benefits include:

* Shared by the entire team
* Centralized storage
* Version history (when bucket versioning is enabled)
* Automatic backups
* Easier collaboration

Example backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "terraform/day19/terraform.tfstate"
    region = "us-east-1"
  }
}
```

After configuring the backend, Terraform uploads the state file to S3.

---

# State Locking

Terraform prevents multiple users from modifying infrastructure simultaneously.

Historically, this was accomplished using an Amazon DynamoDB table.

Terraform would:

1. Acquire a lock
2. Read the state
3. Apply changes
4. Release the lock

If another user attempted to run Terraform while the lock existed, Terraform would wait until the lock was released.

---

# Terraform Version Changes

While configuring state locking, I discovered that newer versions of Terraform have deprecated the following setting:

```hcl
dynamodb_table = "terraform-locks"
```

The recommended approach is now:

```hcl
use_lockfile = true
```

Terraform creates a temporary lock file directly inside the S3 bucket instead of using DynamoDB.

Although DynamoDB locking is being phased out, understanding it is still valuable because many existing Terraform deployments continue to use it.

---

# Commands Used

Initialize Terraform:

```bash
terraform init
```

Deploy Development:

```bash
terraform apply -var-file=dev.tfvars
```

Deploy Production:

```bash
terraform apply -var-file=prod.tfvars
```

Destroy Infrastructure:

```bash
terraform destroy -var-file=prod.tfvars
```

Reconfigure backend:

```bash
terraform init -reconfigure
```

---

# Key Takeaways

* Terraform projects should be reusable across multiple environments.
* Variable files allow the same code to deploy Development, Testing, or Production infrastructure.
* Terraform relies on a state file to track managed resources.
* Remote state stored in S3 enables collaboration between team members.
* Modern Terraform versions support native S3 lock files (`use_lockfile = true`) instead of requiring DynamoDB for state locking.
* Proper resource tagging is an important best practice for managing cloud infrastructure.

---

# Reflection

Today's lab introduced concepts that move Terraform beyond single-user projects into real-world team environments.

I learned how organizations manage multiple environments using variable files, why Terraform state is essential, and how remote state allows multiple engineers to safely collaborate. I also learned that Terraform continues to evolve, replacing DynamoDB-based state locking with native S3 lock files in newer versions.

This lab helped me understand not only how Terraform provisions infrastructure, but also how teams manage that infrastructure safely and consistently over time.
