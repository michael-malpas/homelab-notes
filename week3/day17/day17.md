# Day 17

## Concepts

Terraform local_file
Terraform templatefile
Dynamic Inventory
Variables
tfvars

## Workflow
```
Terraform
→ Create EC2

Terraform
→ Generate Inventory

Ansible
→ Configure Server
```

## Stretch Goal
Updated terraform to create multiple instances

worked through troubleshooting to get it to display both ip's, name each with a variable web1/web2 etc

udpated outputs.tf and variables.tf to work with multiple instances.

tested automating adding ssh keys to known_hosts file.

## End-of-Day Success Checklist
Able to explain:
- What Terraform does
- What ansible does
- Why infrastructure as code matters
- what an inventory file is/does
- why idempotency matters
- how terraform and Ansible work together

Created a realistic workflow:
```
Terraform
    ↓
Creates EC2
    ↓
Generates Inventory
    ↓
Ansible Connects
    ↓
Installs Software
    ↓
Configures Server
```

## Next Steps
Incorporating GitHub actions to trigger terraform and ansible automatically

Start to see something that resembles a real CI/CD pipeline
