# open this as raw copy url and run `curl <url> > run.sh && sh run.sh`
python3 -m pip install --upgrade pip
pip3 install boto3

# printf "python3 -m pip install --upgrade pip \npip install flask \nprintf \"from flask import Flask\\napp = Flask(__name__)\\n@app.route('/')\\ndef my_app():\\n  return 'app'\" > app.py\napp.py flask run --port 8080\n" > deployflask.sh

# printf '#!%s'"/bin/bash \napt-get update \napt-get install -y python3 \napt-get install -y python3-pip \napt-get install -y nginx \napt-get install -y gunicorn3 \nmkdir flask_application \ncd flask_application \npip install Flask \necho \"from flask import Flask \napp = Flask(__name__) \n@app.route('/') \ndef my_app(): \n\treturn 'First Flask Application' \nif __name__=='__main__': \n\tapp.run(host='0.0.0.0', port=8080)\" > my_app.py \ncd /etc/nginx/ \ncd sites-enabled/ \necho \"server { \nlisten 80; \n\tserver_name \">flaskapp \ncurl http://169.254.169.254/latest/meta-data/public-ipv4 >> flaskapp \necho \"; \n\nlocation / { \n\tproxy_pass http://127.0.0.1:8000; \n\t} \n}\" >> flaskapp \nservice nginx restart \ncd ~ \ncd /flask_application \ngunicorn3 my_app:my_app" > deployFlask.sh

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

# ECSImageId=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs*" --query 'sort_by(Images, &CreationDate)[].Name' --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)
ECSImageId=ami-09a41e26df464c548

DefaultSecurityGroup = $(aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --filters Name=group-name,Values=default --output text)
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


## create target group
aws elbv2 create-target-group --name cluster1 --protocol HTTP --port 80 --target-type instance --vpc-id vpc-0d6def933ebef8c51
aws elbv2 create-target-group --name cluster2 --protocol HTTP --port 80 --target-type instance --vpc-id vpc-0d6def933ebef8c51

#stocker les TargetGroupArn
TargetGroupArn1=$(aws elbv2 describe-target-groups --query 'TargetGroups'[0].TargetGroupArn --output text)
TargetGroupArn2=$(aws elbv2 describe-target-groups --query 'TargetGroups'[1].TargetGroupArn --output text)

## add instances to target-group
#TO DO : obtenir les instance id 

#cluster 1
#aws elbv2 register-targets --target-group-arn TargetGroupArn1  -targets Id=#TO DO instance ID i-0abcdef1234567890 Id=i-1234567890abcdef0
#cluster 2
#aws elbv2 register-targets --target-group-arn TargetGroupArn2  -targets Id=TO DO i-0abcdef1234567890 Id=i-1234567890abcdef0


## create loadbalancer 
aws elbv2 create-load-balancer --name my-load-balancer  --subnets subnet-04f197a80f791c8ed  subnet-0e39e8d6bc1a91173 

#stocker LoadBalancerArn
LoadBalancerArn=$(aws elbv2 describe-load-balancers --query 'LoadBalancers'[0].LoadBalancerArn --output text)


##setup listener rules of the loadbalancer 
aws elbv2 create-listener --load-balancer-arn $LoadBalancerArn --protocol HTTP --port 80  --default-actions Type=forward,TargetGroupArn=$TargetGroupArn1

#listener arn
ListenerArn1=$(aws elbv2 describe-listeners --load-balancer-arn $LoadBalancerArn --query 'Listeners'[0].ListenerArn --output text)

aws elbv2 create-rule --listener-arn $ListenerArn1 --priority 10 --conditions Field=path-pattern,Values='/cluster1' --actions Type=forward,TargetGroupArn=$TargetGroupArn1
aws elbv2 create-rule --listener-arn $ListenerArn1 --priority 9 --conditions Field=path-pattern,Values='/cluster2' --actions Type=forward,TargetGroupArn=$TargetGroupArn2

   

#delete loadbalancer 
aws elbv2 delete-load-balancer --load-balancer-arn $LoadBalancerArn

#get targetgroup arn and delete the two targetgroups one by one
aws elbv2 delete-target-group --target-group-arn $TargetGroupArn1
aws elbv2 delete-target-group --target-group-arn $TargetGroupArn2

# terminate all instances
# aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" --output text)
