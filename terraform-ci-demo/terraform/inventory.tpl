[web]

%{ for ip in public_server_ips ~}
${ip}
%{ endfor ~}

[web:vars]

ansible_user=ubuntu
ansible_ssh_private_key_file=/home/michael/aws/devops-lab-key.pem

[app]

%{ for ip in private_server_ips ~}
${ip}
%{ endfor ~}

[app:vars]

ansible_user=ubuntu
ansible_ssh_private_key_file=/home/michael/aws/devops-lab-key.pem
