#!/bin/bash
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
pip install subprocess
echo "from flask import Flask
import subprocess
app = Flask(__name__)
instance_id = subprocess.check_output(['curl', 'http://169.254.169.254/latest/meta-data/instance-id'])
@app.route('/')
def my_app():
    return 'Instance '+ instance_id + ' is responding now'
if __name__=='__main__':
    app.run()" > my_app.py

echo "[Unit]
Description=Gunicorn instance for a simple flask app
After=network.target

[Service]
User=admin
WorkingDirectory=/flask_application
ExecStart=/flask_application/venv/bin/gunicorn -b localhost:8080 my_app:app
Restart=always

[Install]
WantedBy=multi-user.target"> /etc/systemd/system/flaskapp.service
systemctl daemon-reload
systemctl start flaskapp
systemctl enable flaskapp

systemctl start nginx
systemctl enable nginx

echo "upstream flaskflaskapp {
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
}" > /etc/nginx/sites-available/default

systemctl restart nginx