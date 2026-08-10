#!/bin/bash

set -euxo pipefail

# ----------------------------------------
# Wait for network connectivity
# ----------------------------------------

echo "Waiting for network connectivity..."

for i in {1..12}; do
    if curl -4 -s --connect-timeout 5 http://archive.ubuntu.com >/dev/null; then
        echo "Network connectivity confirmed."
        break
    fi

    if [ "$i" -eq 12 ]; then
        echo "Network connectivity could not be established."
        exit 1
    fi

    echo "Network not ready. Attempt $i/12. Retrying in 5 seconds..."
    sleep 5
done


# ----------------------------------------
# Update package repositories
# ----------------------------------------

echo "Updating package repositories..."

APT_UPDATED=false

for i in {1..5}; do
    if apt-get update; then
        APT_UPDATED=true
        echo "apt-get update succeeded."
        break
    fi

    echo "apt-get update failed. Attempt $i/5."

    if [ "$i" -lt 5 ]; then
        echo "Retrying in 15 seconds..."
        sleep 15
    fi
done

if [ "$APT_UPDATED" != "true" ]; then
    echo "ERROR: apt-get update failed after 5 attempts."
    exit 1
fi


# ----------------------------------------
# Install required packages
# ----------------------------------------

echo "Installing required packages..."

apt-get install -y \
    python3 \
    python3-pip \
    nginx \
    curl \
    git \
    htop \
    tree \
    unzip


# ----------------------------------------
# Start nginx
# ----------------------------------------

echo "Starting nginx..."

systemctl enable nginx
systemctl start nginx


# ----------------------------------------
# Retrieve EC2 metadata
# ----------------------------------------

echo "Retrieving EC2 metadata..."

TOKEN=$(curl -s -X PUT \
    "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

AZ=$(curl -s \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    "http://169.254.169.254/latest/meta-data/placement/availability-zone")


# ----------------------------------------
# Create web page
# ----------------------------------------

echo "Creating nginx web page..."

cat <<EOF > /var/www/html/index.html
<h1>Terraform CI/CD Demo</h1>
<p>Served through an AWS Application Load Balancer</p>
<p>Private EC2 Instance</p>
<p>Hostname: $(hostname)</p>
<p>Availability Zone: $AZ</p>
EOF


# ----------------------------------------
# Create deploy user
# ----------------------------------------

echo "Creating deploy user..."

if ! id deploy >/dev/null 2>&1; then
    useradd -m -s /bin/bash deploy
fi

mkdir -p /home/deploy/.ssh

chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh


# ----------------------------------------
# Verify nginx
# ----------------------------------------

echo "Verifying nginx..."

systemctl is-active --quiet nginx

curl -f http://localhost/ >/dev/null

echo "========================================="
echo "User-data completed successfully."
echo "Hostname: $(hostname)"
echo "Availability Zone: $AZ"
echo "Nginx is running."
echo "========================================="
