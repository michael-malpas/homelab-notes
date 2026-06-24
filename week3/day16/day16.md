# Day 16

## Concepts

Terraform creates infrastructure

Ansible configures infrastructure

## Workflow
```
Terraform
→ EC2

Ansible
→ Install nginx
```
## Commands

terraform apply

terraform output public_ip

ansible -i inventory.ini web -m ping

ansible-playbook -i inventory.ini install_nginx.yml

## End-of-Day Success Checklist
- Terraform created EC2
- Security Group created
- Public IP output works
- SSH connectivity verified
- Ansible inventory created
- Ansible ping successful
- Nginx installed automatically
- Website accessible
- Playbook proven idempotent
- Terraform destroy completed
