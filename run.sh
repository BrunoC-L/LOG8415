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
#SecurityGroup=$(aws ec2 create-security-group --description "Flask Group" --group-name flask-group --output text)
SecurityGroup=sg-0666cf92245a33566
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 22   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 80   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 8080 --cidr 0.0.0.0/0

aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://deployFlask.sh --query "Instances[].[InstanceId]" --output text

# terminate all instances
# aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" --output text)
