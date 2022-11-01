#!/bin/bash

echo "setup starting" >> /var/log/user-data.log

# INSTALLATION OF DOCKER
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

# Getting our dockerfile to create an ubuntu image with hadoop and spark already installed
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/Dockerfile > dockerfile
cat dockerfile > /var/log/user-data-dockerfile.log

# Building the image
echo "Docker build starting" >> /var/log/user-data.log
sudo docker build -t hadoopsparkimage - < dockerfile &>> /var/log/docker-build.log
echo "Docker build completed" >> /var/log/user-data.log

ImageId=$(sudo docker images "hadoopsparkimage*" --format "{{.ID}}")

# Running a docker container with our custom image
echo "Docker run starting using image $ImageId" >> /var/log/user-data.log
sudo docker run -d --name hdpcontainter $ImageId
ContainerID=$(sudo docker ps -a --format "{{.ID}}")
echo $ContainerID
dockerDone=false
# while [ $dockerDone == false ]
# do
#    dockerDone=$(docker exec -it mysqlserver sh -c "test -d /socialResult")
#    sleep 10
# done

# Getting the results of the scripts that ran on the docker container
# sudo docker cp $ContainerID:/socialResult.txt /var/log/socialResult.txt
# sudo docker cp $ContainerID:/hadoopSparkResult.txt /var/log/hadoopSparkResult.txt
# sudo docker cp $ContainerID:/linuxHadoopResult.txt /var/log/linuxHadoopResult.txt
echo "Docker run completed" >> /var/log/user-data.log
