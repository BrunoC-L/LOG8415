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
fi

# standalone="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-standalone.sh --query "Instances[].[InstanceId]" --output text)"
# standaloneIP=$(aws ec2 describe-instances --instance-id $standalone --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
# echo standalone $standaloneIP

master="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --subnet-id=$Subnet --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-cluster-master.sh --query "Instances[].[InstanceId]" --output text)"
masterIP=$(aws ec2 describe-instances --instance-id $master --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
echo master $masterIP

worker="$(aws ec2 run-instances --image-id $ECSImageId --count 3 --subnet-id=$Subnet --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://mysql-cluster-worker.sh --query "Instances[].[InstanceId]" --output text)"
workerIP=$(aws ec2 describe-instances --instance-id $worker --query "Reservations[].Instances[].PublicIpAddress[]" --output text)
echo workers $workerIP
