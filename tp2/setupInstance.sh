#!/bin/bash

apt-get update
apt-get remove docker docker-engine docker.io containerd runc

# Setting up the repository to install docker
apt-get update
apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker engine
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo REPLACE_DOCKERFILE > dockerfile
echo "Docker build starting" >> /var/log/user-data.log
sudo docker build - < dockerfile &>> /var/log/docker-build.log
echo "Docker build completed" >> /var/log/user-data.log
