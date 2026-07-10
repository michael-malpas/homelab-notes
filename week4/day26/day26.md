# Day 26 Notes – Refactoring Infrastructure with Terraform Modules

## Overview

Today's lesson focused on improving the maintainability and scalability of the Terraform configuration by introducing **Terraform modules**.

Up to this point, all infrastructure resources were defined within a single `main.tf` file. While this approach works well for small projects, it becomes increasingly difficult to manage as infrastructure grows.

To address this, the EC2 instance configuration was refactored into a reusable child module. Rather than defining every resource directly in the root module, the root module now passes configuration values into the EC2 module, allowing the infrastructure to be organized into smaller, reusable components.

This represents an important shift from simply writing Terraform code to designing infrastructure that can scale and be maintained by multiple engineers.

---

## What is a Terraform Module?

A Terraform module is a reusable collection of Terraform resources.

Every Terraform project has a **root module**, which is the directory where Terraform commands such as `terraform init`, `terraform plan`, and `terraform apply` are executed.

Additional **child modules** can be created to encapsulate specific infrastructure components, such as EC2 instances, networking, security groups, or databases.

The root module defines **what** infrastructure should exist, while child modules define **how** that infrastructure is created.

---

## Why Use Modules?

As infrastructure grows, copying and pasting resource blocks quickly becomes difficult to maintain.

Modules provide several advantages:

* Reduce duplicated code.
* Improve readability.
* Standardize infrastructure deployments.
* Simplify maintenance.
* Allow infrastructure to be reused across multiple environments.

Instead of maintaining multiple copies of nearly identical resources, a single module can be reused with different input values.

---

## Creating the EC2 Module

A new directory structure was created within the Terraform project:

```text
terraform/
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

This module is responsible only for creating EC2 instances.

Keeping the module focused on a single responsibility makes it easier to understand, test, and reuse in future projects.

---

## Module Inputs

One of the most important concepts introduced today was **module inputs**.

The original EC2 resource referenced variables, data sources, and resources defined throughout the root module.

To make the EC2 module reusable, these dependencies were converted into input variables.

The EC2 module now receives values such as:

* Instance count
* AMI ID
* Instance type
* Key pair name
* User data
* Security group ID
* Environment name
* Server name

Rather than discovering these values itself, the module receives them from the root module.

This allows the same module to create different types of EC2 instances simply by changing the input values.

---

## Module Outputs

Modules can also return information back to the root module using **outputs**.

Examples include:

* Instance ID
* Public IP address
* Private IP address

Instead of directly referencing the EC2 resource, the root module accesses these values through module outputs.

This creates a cleaner separation between the infrastructure implementation and the rest of the Terraform configuration.

---

## Root Module vs Child Module

Today's lesson highlighted the distinction between Terraform's two module types.

**Root Module**

Responsible for:

* AWS provider configuration
* Backend configuration
* AMI lookups
* Security groups
* Reading user data files
* Calling child modules

**Child Module**

Responsible for:

* Creating EC2 instances
* Applying tags
* Exposing useful outputs

This separation keeps each module focused on a single purpose and reduces coupling between infrastructure components.

---

## Design Decisions

Several design decisions were made during today's refactoring.

### Passing the AMI ID

Rather than performing the AMI lookup inside the EC2 module, the root module continues to retrieve the latest Ubuntu AMI and passes the resulting AMI ID into the module.

This keeps the EC2 module generic and allows it to be reused with different operating systems in the future.

### Passing User Data

Instead of having the EC2 module read `userdata.sh` directly, the root module reads the file and passes its contents into the module.

This avoids file path issues and makes the module independent of any specific initialization script.

### Passing the Security Group

The security group remains in the root module.

Rather than creating networking resources inside the EC2 module, the module receives the security group ID as an input.

Keeping networking separate from compute resources follows the principle of single responsibility and allows the same security group to be reused by multiple resources.

---

## Benefits of Modular Design

By introducing modules, the Terraform configuration is now:

* Easier to understand.
* Easier to extend.
* Easier to reuse.
* Easier to test.
* Better aligned with enterprise Infrastructure as Code practices.

As the project continues to grow, additional modules can be created for networking, IAM, databases, monitoring, and other infrastructure components without significantly increasing the complexity of the root module.

---

## Key Concepts Learned

* Terraform modules package infrastructure into reusable components.
* The root module coordinates infrastructure, while child modules implement individual components.
* Module variables act as inputs.
* Module outputs expose useful information back to the root module.
* Passing dependencies into a module makes it more reusable and less tightly coupled to the rest of the project.
* Modular Infrastructure as Code is easier to maintain than a single large Terraform configuration.

---

## Takeaways

Today's lesson marked an important transition from building infrastructure to designing infrastructure.

Rather than focusing solely on creating AWS resources, the emphasis shifted toward writing Terraform code that is organized, reusable, and maintainable over time.

This mirrors how infrastructure is managed within larger engineering teams, where reusable modules reduce duplication, simplify collaboration, and enable consistent deployments across multiple environments.

As the homelab continues to expand, this modular approach will provide a solid foundation for introducing additional infrastructure components without significantly increasing project complexity.
