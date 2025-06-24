#!/usr/bin/env bash

#security flags
set -eu


#Replaces extensive output with short messages about the current
#status of the task by using "> /dev/null" redirect
echo "Prepare installation, remove old packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc;
do sudo apt-get remove $pkg > /dev/null;
done


#Update packages
echo "Updating..."
sudo apt-get update > /dev/null


# Add Docker's official GPG key and Install certificates for repository verification
echo "Install ca-certificates..."
sudo apt-get install -y ca-certificates curl > /dev/null
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update > /dev/null


#Install packages
echo "Install Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null


#ADD SERVICE CHECK systemctl is-active docker.service
#......


#Test installation
echo "Start Docker and check..."
sudo docker run hello-world > /dev/null
if [[ $? == 0 ]]; then echo "Installation complete!"; fi