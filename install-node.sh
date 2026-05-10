#!/bin/bash
NODE1_HOSTNAME="$1"
NODE1_IP="$2"


echo "Installing for host: $NODE1_HOSTNAME"
sudo dnf update -y && sudo dnf upgrade -y
sudo dnf install ansible-core git wget curl zip unzip net-tools podman python3 -y

sed 's/^::1/# ::1/' /etc/hosts | sudo tee /etc/hosts > /dev/null
echo "127.0.0.1   $NODE1_HOSTNAME" | sudo tee -a /etc/hosts
echo "$NODE1_IP    $NODE1_HOSTNAME"  | sudo tee -a /etc/hosts

sudo hostnamectl set-hostname $NODE1_HOSTNAME