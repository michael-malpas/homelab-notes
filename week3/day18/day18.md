# EC2 User Data & Server Bootstrapping

## Objective

Learn how to use EC2 User data (cloud-init) to automatically boostrap an EC2 instance during its first boot and understand how this differs from configuration managmenet with Ansible.

## What I Learned

### What is EC2 User Data?

User data is a script that AWS passes to a newly created EC2 instance. During the instance's first boot, the cloud-init service executes the script automatically.

This allows the instance to perform initial configuration without requiring me to SSH into the server.

Typical tasks include:
- updating package repositories
- installing required software
- creating users
- configuring services
- preparing the system for configuration management tools like ansible

Unlike Ansible, User Data runs only once during the initial boot process. Any changes made to the user data script will not be run on terraform updates.

### What is cloud-init?

cloud-init is the Linux service responsible for processing EC2 User Data.

When a new instance start, cloud-init:
1. Detects cloud metadata
2. Downloads the User Data script
3. Executes the script
4. Records logs of everything that occurred

Cloud-init is installed by default on ubuntu cloud images

### User Data Script

Created bootstrap script named:

userdata.sh

The script performs the following actions:

- updates package repositores
- installs:
	- python 3
	- python 3-pip
	- nginx
	- curl
	- git
	- htop
	- tree
	- unzip
- enables nginx
- starts nginx
- replaces the default nginx webpage with a custom page

Terraform uploads this script automatically using:

user_data = file("${path.module}/userdata.sh")

### Terraform vs User Data vs Ansible

#### Terraform

Responsible for provisioning infrastructure

Examples:

- EC2 instances
- Security Groups
- Networking
- EBS Volumes

Terraform creates resources but generally does not configure the operating system

#### User Data

Responsible for initial server bootstrap

Runs:
- once
- during first boot

Best suited for:

- installing prerequisite software
- updating packages
- creating users
- preparing the operating system

#### Ansible

Responsible for configuration management.

Runs:
- any time
- multiple times
- idempotently

Best suited for:
- managing configuration files
- deploying applications
- managing services
- enforcing desired state

### Why Install Python in user data?

Ansible relies on Python to execute most of its modules on remote linux system.s

Installing python during boot ensures Ansible can immediately connect and begin configuring the server

### Cloud-init troubleshooting

Useful commands:

check cloud-init status:
```bash
sudo cloud-init status
```

View cloud-init log:
```bash
sudo cat /var/log/cloud-init.log
```

View User Data Output:
```bash
sudo cat /var/log/cloud-init-output.log
```

If User Data does not behave as expected, these logs shoudl be checked before modifying Terraform

## Verification Steps

Verified:
- EC2 instances succesfully created
- User Data executed during first boot
- Nginx automatically installed
- Custom webpage displayed
- Python installed
- Cloud-init completed successfully
- Ansible successfully connected after provisioning

## Key Takeaways

- Terraform creates infrastructure
- User Data bootstraps a new server
- Cloud-init executes User Data during first boot
- Ansible performs ongoing configuration management
- Separating provisioning from configuration creates cleaner, more maintainable automation workflows.

## Commands used

Deploy Infrastructure:
```bash
terraform apply
```

Check cloud-init status:
```bash
sudo cloud-init status
```

View cloud-init logs
```bash
sudo cat /var/log/cloud-init.log
```

View user Data output:
```bash
sudo cat /var/log/cloud-init-output.log
```

Run Ansible playbook
```bash
ansible-playbook -i inventory.ini configure.yml
```

Destroy infrastructure
```bash
terraform destroy
```


## Reflection

Today's lab demonstrated how Terraform, cloud-init, and Ansible each have distinct responsibilities in an Infrastructure as Code workflow.

Rather than manually configuring new servers, the provisioning process can be automated from the moment the EC2 instance launches. User Data prepares the operating system, while Ansible handles long-term configuration management. This separation results in infrastructure that is more repeatable, scalable, and easier to maintain.
