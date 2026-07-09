# Day 25 Notes – GitHub Environments & Protected Deployments

## Overview

Today's lesson focused on improving the safety and governance of the Infrastructure as Code deployment pipeline by introducing **GitHub Environments** and **deployment protection rules**.

Previously, Terraform automatically applied infrastructure changes whenever code was merged into the `main` branch. While this approach works, it lacks an additional layer of control before modifying cloud infrastructure.

By introducing a protected **production** environment, deployments now require explicit approval before Terraform is allowed to apply infrastructure changes. This more closely reflects how production deployments are managed within enterprise DevOps teams.

---

## What are GitHub Environments?

GitHub Environments provide a mechanism for controlling deployments to different stages of an application's lifecycle.

Common examples include:

* Development
* Testing
* Staging
* Production

Each environment can have its own:

* Secrets
* Variables
* Deployment protection rules
* Required reviewers
* Wait timers
* Branch restrictions

This allows organizations to apply different security and approval requirements depending on the environment being deployed.

---

## Creating the Production Environment

A new environment named **production** was created within the GitHub repository under:

**Settings → Environments**

Although this project is a learning environment, using a production environment demonstrates how real-world deployment pipelines are structured and prepares the project for future expansion into multiple environments.

---

## Deployment Protection Rules

The production environment was configured with a **Required Reviewer**.

This changes the deployment process from:

Feature Branch → Pull Request → Merge → Terraform Apply

to:

Feature Branch → Pull Request → Merge → Deployment Approval → Terraform Apply

When infrastructure changes are merged into `main`, GitHub Actions pauses the deployment until an authorized reviewer approves it.

This approval gate helps prevent accidental or unreviewed infrastructure changes from reaching production.

---

## Connecting GitHub Actions to the Environment

The Terraform deployment workflow was updated by adding an environment declaration to the deployment job.

Once associated with the production environment, GitHub automatically enforced the configured protection rules before allowing the workflow to continue.

This required only a small change to the workflow configuration while significantly improving deployment safety.

---

## Repository Secrets vs Environment Secrets

Until now, AWS credentials have been stored as **Repository Secrets**, making them available to all workflows within the repository.

GitHub also supports **Environment Secrets**, which are scoped to individual deployment environments.

For example:

* Development AWS credentials
* Staging AWS credentials
* Production AWS credentials

Using environment-specific secrets limits credential exposure and ensures deployments use the appropriate cloud account for each environment.

Although repository secrets remain sufficient for this homelab, understanding environment secrets is an important step toward enterprise CI/CD practices.

---

## Why Deployment Approvals Matter

Infrastructure automation should improve consistency, but automation should not eliminate human oversight.

Requiring approval before deploying infrastructure provides several benefits:

* Prevents accidental deployments.
* Allows infrastructure changes to be reviewed one final time.
* Reduces the likelihood of outages caused by incorrect configuration.
* Encourages accountability within deployment processes.
* Creates an auditable record of who approved each deployment.

These approval gates are commonly found in production CI/CD pipelines where infrastructure changes can affect large numbers of users or critical business systems.

---

## Operational Considerations

Today's lesson also highlighted that deployment approvals are not only about technical correctness but also operational responsibility.

Before approving an infrastructure deployment, engineers should consider questions such as:

* Does this change create additional AWS resources?
* Will it increase infrastructure costs?
* Does it modify existing production systems?
* Is the deployment occurring during an appropriate maintenance window?
* Is there a rollback strategy if the deployment fails?

Thinking beyond the Terraform code itself is an important part of developing a DevOps mindset.

---

## Key Concepts Learned

* GitHub Environments provide an additional layer of deployment control.
* Deployment protection rules can require manual approval before infrastructure changes are applied.
* Environment-specific secrets allow different credentials to be used for different deployment targets.
* Approval gates reduce the operational risk associated with automated infrastructure deployments.
* Enterprise CI/CD pipelines balance automation with governance rather than automating every action indiscriminately.

---

## Takeaways

Today's lesson shifted the focus from **automation** to **controlled automation**.

Rather than allowing every merge to immediately modify cloud infrastructure, the deployment pipeline now includes a deliberate approval stage that mirrors real-world production environments.

This demonstrated that mature DevOps practices are not solely about increasing automation—they are about implementing automation responsibly while maintaining operational safety, accountability, and governance.

With deployment approvals now integrated into the pipeline, the Terraform CI/CD project more closely resembles the deployment workflows used by professional engineering teams.
