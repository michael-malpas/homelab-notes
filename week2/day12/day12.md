# Day 12 - Infrastructure as Code (Terraform Fundamentals)

## Goals
- Understand Infrastructure as Code
- Install Terraform
- Learn Terraform syntax
- Create first resources
- use variables
- use outputs
- understand state files
- build a small lab project

## Install Terraform
Check if available
```bash
terraform version
```

If not:
```bash
sudo apt update
sudo apt install wget gpg -y
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Install:
```bash
sudo apt update
sudo apt install terraform -y
```

Verify:
```bash
terraform version
```

## Create Terraform Lab
