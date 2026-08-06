#!/bin/bash

apt update

apt install -y python3 python3-pip nginx curl git htop tree unzip

systemctl enable nginx
systemctl start nginx

echo \
<h1>Terraform CI/CD Demo</h1> \
<p>Served through an AWS Application Load Balancer</p> \
<p>Private EC2 Instance</p> > /var/www/html/index.html

useradd -m deploy

mkdir /home/deploy/.ssh

chown -R deploy:deploy /home/deploy/.ssh
