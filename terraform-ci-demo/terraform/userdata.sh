#!/bin/bash

apt update

apt install -y python3 python3-pip nginx curl git htop tree unzip

systemctl enable nginx
systemctl start nginx

echo "Provisioned by Terraform User Data" > /var/www/html/index.html

useradd -m deploy

mkdir /home/deploy/.ssh

chown -R deploy:deploy /home/deploy/.ssh
