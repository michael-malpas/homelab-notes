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
Create:
```bash
mkdir terraform-lab
cd terraform-lab
```

Create:
```bash
touch main.tf
```

## Learn Terraform Structure/ First Resource
Open:
```bash
nano main.tf
```

Add:
```hcl
terraform {
  required_version = ">= 1.0"
}

resource "local_file" "welcome" {
  filename = "welcome.txt"
  content  = "Hello from Terraform!"
}
```

## Initialize Terraform
Run:
```bash
terraform init
```

Expected:
```
Terraform has been successfully initialized
```

This creates:
```
.terraform/
```

## Create Execution Plan
Run:
```bash
terraform plan
```

Observe:
```
Create local_file.welcome
```

Translation:
```
I will create this file
```

Nothing has been done yet, this is just the planning stage to show what terraform will do

## Apply Changes
Run
```bash
terraform apply
```

It will prompt for input, yes will move forward, anything else will cancel

Expected:
```
Apply complete!
```

Verify: 
```bash
cat welcome.txt
```

Output:
```
Hello from Terraform!
```

## State Files 
notice:
```
terraform.tfstate
```

View:
```bash
cat terraform.tfstate
```

Terraform tracks:
- what exists
- what was created
- what needs to be changed
through states

## Modify Infrastructure
Change main.tf
```hcl
content = "Updated by Terraform"
```

run:
```bash
terraform plan
```

Observe:

Terraform indicates files may need to be changed/replaced and what steps it's going to take now

Apply:
```bash 
terraform apply
yes
```

Verify:
```bash
cat welcome.txt
```

Observe changes

## Destroy Infrastructure
Run:
```bash
terraform destroy
yes
```

Observe:
```
Destroy compelte
```

files removed and plan destroyed

Terraform does create terraform.tfstate.bakup which will contain the previous tfstate which can be useful if needed

## Variables
Create:
```bash
nano variables.tf
```

add:
```hcl
variable "username" {
  default = "michael"
}
```

Update main.tf
```hcl
resource "local_file" "welcome" {

  filename = "welcome.txt"

  content = "Welcome ${var.username}"
}
```

Apply:
```bash
terraform apply
yes
```

Verify:
```bash
cat welcome.txt
```

Output:
```
Welcome michael
```

## Outputs
Create:
```bash
nano outputs.tf
output "file_name" {
  value = local_file.welcome.filename
}
```

Run:
```bash
terraform apply
```

Observe:
```
file_name = "welcome.txt"
```

This adds output to the end of the plan, in this case indicating what the filename that was created was/is

## Variable Override
Run:
```bash
terraform apply -var="username=devops"
```

Verify:
```bash
cat welcome.txt
```

Notice it now shows Welcome devops instead

## Terraform Formatting
Run:
```bash
terraform fmt
```

Terraform automatically formats files

## Terraform Validation
Run:
```bash
terraform validate
```

Expected:
```
Success!
```

## GitHub Actions Integration
Create
```bash
~/homelab-notes/.github/workflows/terraform.yml
```

Add:
```yml
name: Terraform Validation

on:
  push:

jobs:

  terraform:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - run: terraform fmt -check

      - run: terraform validate
```

Push to GitHub

Observe automation running

## Create DevOps Style environment
Create:
```bash
mkdir environments
environments/
├── dev
├── test
└── prod
```

This mirrors standard repo infrastructure

## Stretch Goal
Update pipeline to include terraform

