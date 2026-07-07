[web]

%{ for ip in public_ips ~}
${ip}
%{ endfor ~}

[web:vars]

ansible_user=ubuntu
ansible_ssh_private_key_file=/home/michael/aws/devops-lab-key.pem
