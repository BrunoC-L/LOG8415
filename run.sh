# Open this as raw copy url and run `curl <url> > run.sh && sh run.sh`

# Write script to run on the instances as `deployFlask.sh`
echo '#!/bin/bash'"
apt-get update
apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y python3-venv
apt-get install -y python-dev
apt-get install -y virtualenv

apt-get install -y nginx

mkdir flask_application
cd flask_application
virtualenv venv
source venv/bin/activate
pip install flask
pip install gunicorn
echo \"from flask import Flask
import subprocess
app = Flask(__name__)
instance_id = subprocess.check_output(['curl', 'http://169.254.169.254/latest/meta-data/instance-id'])
@app.route('/')
def my_app():
    return 'Instance '+ instance_id + ' is responding now'
if __name__=='__main__':
    app.run()\" > my_app.py

echo \"[Unit]
Description=Gunicorn instance for a simple flask app
After=network.target

[Service]
User=admin
WorkingDirectory=/flask_application
ExecStart=/flask_application/venv/bin/gunicorn -b localhost:8080 my_app:app
Restart=always

[Install]
WantedBy=multi-user.target\"> /etc/systemd/system/flaskapp.service
systemctl daemon-reload
systemctl start flaskapp
systemctl enable flaskapp

systemctl start nginx
systemctl enable nginx

echo \"upstream flaskflaskapp {
    server 127.0.0.1:8080;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;

    server_name _;

    location / {
        proxy_pass http://flaskflaskapp;
    }
}\" > /etc/nginx/sites-available/default

systemctl restart nginx" > deployFlask.sh

python3 -m pip install --upgrade pip
pip3 install boto3

# ECSImageId=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs*" --query 'sort_by(Images, &CreationDate)[].Name' --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)
ECSImageId=ami-09a41e26df464c548

DefaultSecurityGroup=$(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --filters Name=group-name,Values=default --output text)

OldInstances=$(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" --output text)
if [ $OldInstances != "" ] then
    for instance in $OldInstances
    do
        # remove dependency to sg (which means we cant delete sg), this has to be done while the instance is running or stopped (not terminating)
        aws ec2 modify-instance-attribute --instance-id $instance --groups $DefaultSecurityGroup
    done
    aws ec2 terminate-instances --instance-ids $OldInstances
fi

OldGroups=$(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --output text)
for group in $OldGroups
do
    if [ "$group" != "$DefaultSecurityGroup" ]; then
        aws ec2 delete-security-group --group-id $group
    fi
done

SecurityGroup=$(aws ec2 create-security-group --description "Flask Group" --group-name flask-group --output text)
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 22   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 80   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 8080 --cidr 0.0.0.0/0

aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://deployFlask.sh --query "Instances[].[InstanceId]" --output text

VpcId=$(aws ec2 describe-vpcs --query 'Vpcs'[0].VpcId --output text)

# create target groups
Cluster1Name=cluster1
Cluster2Name=cluster2
TargetGroupArn1=$(aws elbv2 create-target-group --name $cluster1Name --protocol HTTP --port 80 --target-type instance --vpc-id $VpcId --query 'TargetGroups'[0].TargetGroupArn --output text)
TargetGroupArn2=$(aws elbv2 create-target-group --name $cluster2Name --protocol HTTP --port 80 --target-type instance --vpc-id $VpcId --query 'TargetGroups'[0].TargetGroupArn --output text)

# add instances to target-group
# TODO : obtenir les instance id 

#cluster 1
#aws elbv2 register-targets --target-group-arn TargetGroupArn1 -targets Id=TODO instance ID i-0abcdef1234567890 Id=i-1234567890abcdef0
#cluster 2
#aws elbv2 register-targets --target-group-arn TargetGroupArn2 -targets Id=TODO i-0abcdef1234567890 Id=i-1234567890abcdef0


# create loadbalancer
# TODO subnet ids
LoadBalancerArn=$(aws elbv2 create-load-balancer --name my-load-balancer --subnets subnet-04f197a80f791c8ed subnet-0e39e8d6bc1a91173 --query 'LoadBalancers'[0].LoadBalancerArn --output text)

# setup listener rules of the loadbalancer 
ListenerArn1=$(aws elbv2 create-listener --load-balancer-arn $LoadBalancerArn --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$TargetGroupArn1 --query 'Listeners'[0].ListenerArn --output text)

aws elbv2 create-rule --listener-arn $ListenerArn1 --priority 10 --conditions Field=path-pattern,Values='/$Cluster1Name' --actions Type=forward,TargetGroupArn=$TargetGroupArn1
aws elbv2 create-rule --listener-arn $ListenerArn1 --priority  9 --conditions Field=path-pattern,Values='/$Cluster2Name' --actions Type=forward,TargetGroupArn=$TargetGroupArn2


aws elbv2 delete-load-balancer --load-balancer-arn $LoadBalancerArn
aws elbv2 delete-target-group --target-group-arn $TargetGroupArn1
aws elbv2 delete-target-group --target-group-arn $TargetGroupArn2
# terminate all instances
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" --output text)
