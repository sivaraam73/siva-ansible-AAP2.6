#!/bin/bash

AAP_HOSTNAME="$1"
AAP_IP="$2"

echo "Starting Installing of AAP for host: $AAP_HOSTNAME"

echo "# ------------------------------------------------------------"
echo "# 1. Set hostname"
echo "# ------------------------------------------------------------"
sudo hostnamectl set-hostname "$AAP_HOSTNAME"


sudo sed -i 's/^::1/# ::1/' /etc/hosts

echo "127.0.0.1   $AAP_HOSTNAME" | sudo tee -a /etc/hosts
echo "$AAP_IP    $AAP_HOSTNAME"  | sudo tee -a /etc/hosts
sudo dnf install -y cloud-utils-growpart
sudo growpart /dev/sda 4
sudo xfs_growfs /

echo "# ------------------------------------------------------------"
echo "# 2. Update OS and install required packages"
echo "# ------------------------------------------------------------"


sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release -y
sudo dnf update -y
sudo dnf upgrade -y
sleep 3
sudo dnf install -y \
  ansible-core \
  git \
  wget \
  curl \
  zip \
  unzip \
  tar \
  net-tools \
  podman \
  nc
  
sudo dnf install python3-pip -y
python3 -m pip install ansible-builder

 


echo "# ------------------------------------------------------------"
echo "# 3. Turn off SELINUX"
echo "# ------------------------------------------------------------"

sudo sed -c -i "s/\SELINUX=.*/SELINUX=disabled/" /etc/sysconfig/selinux
sudo setenforce 0

echo "# ------------------------------------------------------------"
echo "# 4. Extract AAP installer bundle"
echo "# ------------------------------------------------------------"
sudo rm -rf /vagrant/aap > /dev/null
sudo mkdir -p /vagrant/aap

cd /vagrant/
tar -xvf /vagrant/ansible-automation-platform-containerized-setup-bundle-2.6-7-x86_64.tar.gz \
-C aap \
--strip-components=1

cd /vagrant/aap
cp /vagrant/inventory-growth /vagrant/aap/inventory-growth

echo "# ------------------------------------------------------------"
echo "# 5. Locate and patch nodes.yml"
echo "# ------------------------------------------------------------"

NODES_YML="/vagrant/aap/collections/ansible_collections/ansible/containerized_installer/roles/preflight/tasks/nodes.yml"

if [ ! -f "$NODES_YML" ]; then
  echo "ERROR: nodes.yml not found at:"
  echo "$NODES_YML"
  exit 1
fi

echo "Backing up nodes.yml"
echo
sudo cp "$NODES_YML" "${NODES_YML}.bak"
echo
echo "Commenting out unsupported distribution check..."
echo
sudo sed -i '/^- name: Ensure remote nodes use supported distribution$/,/^$/ s/^/# /' "$NODES_YML"
echo
echo "Commenting out RAM check"
sudo sed -i '/^- name: Fail if this machine lacks sufficient RAM$/,/^$/ s/^/# /' "$NODES_YML"
echo

sudo sed -i '/^- name: Ensure remote user is non root$/,/^$/ s/^/# /' "$NODES_YML"
echo

echo "# ------------------------------------------------------------"
echo "# 6. Run AAP containerized installer"
echo "# ------------------------------------------------------------"
echo;echo "Starting AAP installation using ansible-playbook..."

cd /vagrant/aap

ansible-playbook -i inventory-growth ansible.containerized_installer.install

if [ $? -eq 0 ]; then
    echo "AAP installation completed for $AAP_HOSTNAME"
fi
