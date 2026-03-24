#!/bin/bash

  set -e

  echo "=== 1. Updating packages ==="
  apt update && apt upgrade -y

  echo "=== 2. Creating a Swap-file (4GB) ==="
  if [ ! -f /swapfile ]; then
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
  sysctl vm.swappiness=10
  echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
  else
  echo "Swap-file already exists, skip"
  fi

  echo "=== 3. Installing Docker and Docker Compose ==="
  apt-get remove docker docker-engine docker.io containerd runc || true
  apt-get install -y ca-certificates curl gnupg lsb-release

  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  echo "=== 4. Docker Logging Driver Configuration ==="
  mkdir -p /etc/docker
  cat <<EOF > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}
EOF
  systemctl restart docker

  echo "=== 5. Firewall Configuration (UFW) ==="
  ufw allow OpenSSH
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw --force enable

  echo "=== 6. Creating working directory ==="
  mkdir -p /opt/nr31
  cd /opt/nr31

echo "VPS was configured successfully! Docker was installed, working directory: /opt/nr31"