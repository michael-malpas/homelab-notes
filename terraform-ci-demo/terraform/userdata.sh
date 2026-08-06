#!/bin/bash

apt update

apt install -y python3 python3-pip nginx curl git htop tree unzip

systemctl enable nginx
systemctl start nginx

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat <<EOF > /var/www/html/index.html
<h1>Terraform CI/CD Demo</h1>
<p>Served through an AWS Application Load Balancer</p>
<p>Private EC2 Instance</p>
<p>Hostname: $(hostname)</p>
<p>Availability Zone: $AZ</p>
EOF


useradd -m -s /bin/bash deploy

mkdir /home/deploy/.ssh

chown -R deploy:deploy /home/deploy/.ssh

chmod 700 /home/deploy/.ssh
