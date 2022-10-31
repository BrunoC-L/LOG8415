#!/bin/bash

python3 -m pip install --upgrade pip
pip3 install --upgrade boto
pip3 install --upgrade awscli

ECSImageId=ami-09a41e26df464c548

DefaultSecurityGroup=$(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --filters Name=group-name,Values=default --output text)
echo $DefaultSecurityGroup
VpcId=$(aws ec2 describe-vpcs --query 'Vpcs'[0].VpcId --output text) #default VPC
echo $VpcId
Zone=$(aws ec2 describe-subnets --filters Name=availability-zone,Values=us-east-1* --query Subnets[0].AvailabilityZone --output text)
echo $Zone

OldInstances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[].Instances[].[InstanceId]" --output text)
echo $OldInstances
if [ "$OldInstances" != "" ]; then
    for instance in $OldInstances
    do
        # remove dependency to sg (which means we cant delete sg), this has to be done while the instance is running or stopped (not terminating)
        aws ec2 modify-instance-attribute --instance-id $instance --groups $DefaultSecurityGroup
    done
    aws ec2 terminate-instances --instance-ids $OldInstances
    sleep 10
fi

OldGroups=$(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --output text)
for group in $OldGroups
do
    if [ "$group" != "$DefaultSecurityGroup" ]; then
        aws ec2 delete-security-group --group-id $group
    fi
    sleep 10
done

SecurityGroup=$(aws ec2 create-security-group --description "tp2-group" --group-name tp2-group --output text)
# enable inbound ssh to debug and http for us to view the webapp
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 22   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 80   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 443  --cidr 0.0.0.0/0
# for downloads, enable http/https outbound
aws ec2 authorize-security-group-egress  --group-id $SecurityGroup --protocol tcp --port 80   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-egress  --group-id $SecurityGroup --protocol tcp --port 443  --cidr 0.0.0.0/0

# create script for --user-data
cat install-hadoop.sh > install-hadoop-mod.sh
for file in core hdfs mapred yarn
do
    python3 replaceInFileWithFile.py install-hadoop-mod.sh FILE_$file hadoop_file_overwrites/$file-site.xml "echo '" "'" > temp.sh
    cat temp.sh > install-hadoop-mod.sh
done
rm temp.sh

python3 replaceInFileWithFile.py setupInstance.sh REPLACE_DOCKERFILE dockerfile '"' '"' > setupInstance-mod.sh

# M4Large="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type m4.large --security-group-ids $SecurityGroup --key-name vockey --user-data file://install-hadoop-mod.sh --placement AvailabilityZone=$Zone --query "Instances[].[InstanceId]" --output text)"
M4Large="$(aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type m4.large --security-group-ids $SecurityGroup --key-name vockey --user-data file://setupInstance-mod.sh --placement AvailabilityZone=$Zone --query "Instances[].[InstanceId]" --output text)"
echo $M4Large
