#!/bin/bash

python3 -m pip install --upgrade pip
pip3 install --upgrade boto
pip3 install --upgrade awscli

# ubuntu image
ECSImageId=ami-08c40ec9ead489470

DefaultSecurityGroup=$(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --filters Name=group-name,Values=default --output text)
echo $DefaultSecurityGroup
VpcId=$(aws ec2 describe-vpcs --query 'Vpcs'[0].VpcId --output text) #default VPC
echo $VpcId
DefaultSubnet=$(aws ec2 describe-subnets --query 'Subnets'[0].SubnetId --output text) #default Subnet
echo $Subnet

OldInstances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[].Instances[].[InstanceId]" --output text)
echo $OldInstances
if [ "$OldInstances" != "" ]; then
    for instance in $OldInstances
    do
        # remove dependency to sg (which means we cant delete sg), this has to be done while the instance is running or stopped (not terminating)
        aws ec2 modify-instance-attribute --instance-id $instance --groups $DefaultSecurityGroup
    done
    aws ec2 terminate-instances --instance-ids $OldInstances
fi

SecurityGroup=$(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --filter "Name=group-name,Values=project-group" --output text)

if [ "$SecurityGroup" == "" ]; then
    OldGroups=$(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --output text)
    for group in $OldGroups
    do
        if [ "$group" != "$DefaultSecurityGroup" ]; then
            aws ec2 delete-security-group --group-id $group
        fi
        sleep 10
    done
    SecurityGroup=$(aws ec2 create-security-group --description "project-group" --group-name project-group --output text)
    # enable inbound ssh to debug
    aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 22        --cidr 0.0.0.0/0

    #enable http out
    aws ec2 authorize-security-group-egress  --group-id $SecurityGroup --protocol tcp --port 80        --cidr 0.0.0.0/0

    # mysql hosts on 3306
    aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 3306      --cidr 0.0.0.0/0

    # cluster master hosts on 1186
    aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 1186      --cidr 0.0.0.0/0

    # cluster workers hosts on 31186
    aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 31186      --cidr 0.0.0.0/0
fi

single="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-standalone.sh --query "Instances[].[InstanceId]" --output text)"
sleep 2
singleIP=$(aws ec2 describe-instances --instance-id $single --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
echo single $singleIP

master="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --subnet-id=$Subnet --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-cluster-master.sh --query "Instances[].[InstanceId]" --output text)"
sleep 2
masterIP=$(aws ec2 describe-instances --instance-id $master --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
masterPrivateIP=$(aws ec2 describe-instances --instance-id $master --query "Reservations[].Instances[].PrivateIpAddress[]" --output text)
echo master $masterIP $masterPrivateIP

worker1="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --subnet-id=$Subnet --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-cluster-worker.sh --query "Instances[].[InstanceId]" --output text)"
sleep 2
worker1IP=$(aws ec2 describe-instances --instance-id $worker1 --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
worker1PrivateIP=$(aws ec2 describe-instances --instance-id $worker1 --query "Reservations[].Instances[].PrivateIpAddress[]" --output text)
echo worker $worker1IP $worker1PrivateIP

worker2="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --subnet-id=$Subnet --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-cluster-worker.sh --query "Instances[].[InstanceId]" --output text)"
sleep 2
worker2IP=$(aws ec2 describe-instances --instance-id $worker2 --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
worker2PrivateIP=$(aws ec2 describe-instances --instance-id $worker2 --query "Reservations[].Instances[].PrivateIpAddress[]" --output text)
echo worker $worker2IP $worker2PrivateIP

worker3="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --subnet-id=$Subnet --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-cluster-worker.sh --query "Instances[].[InstanceId]" --output text)"
sleep 2
worker3IP=$(aws ec2 describe-instances --instance-id $worker3 --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
worker3PrivateIP=$(aws ec2 describe-instances --instance-id $worker3 --query "Reservations[].Instances[].PrivateIpAddress[]" --output text)
echo worker $worker3IP $worker3PrivateIP

echo "[ndbd default]
NoOfReplicas=1

[ndb_mgmd]
hostname=$masterPrivateIP
datadir=/var/lib/mysql-cluster

[ndbd]
hostname=$worker1PrivateIP
NodeId=2
datadir=/usr/local/mysql/data
ServerPort = 31186

[ndbd]
hostname=$worker2PrivateIP
NodeId=3
datadir=/usr/local/mysql/data
ServerPort = 31186

[ndbd]
hostname=$worker3PrivateIP
NodeId=4
datadir=/usr/local/mysql/data
ServerPort = 31186

[mysqld]
hostname=$masterPrivateIP" > master-config.ini

echo "!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/

[mysqld]
ndbcluster 
skip_ssl
bind-address=0.0.0.0

[mysql_cluster]
ndb-connectstring=$masterPrivateIP" > master-my.cnf

echo "[mysql_cluster]
ndb-connectstring=$masterPrivateIP" > worker-my.cnf
