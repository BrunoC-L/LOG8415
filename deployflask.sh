#!/bin/bash
apt-get update
apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y nginx

IpAddress=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

mkdir flask_application
cd flask_application
python3 -m venv venv
source venv/bin/activate
pip install Flask
pip install gunicorn
echo "from flask import Flask
app = Flask(__name__)
@app.route('/')
def my_app():
    return 'First Flask Application'
if __name__=='__main__':
    app.run()" > my_app.py

cd /etc/nginx/
cd sites-enabled/
echo "server {
    listen 80;
    server_name " > flaskapp
curl http://169.254.169.254/latest/meta-data/public-ipv4 >> flaskapp
echo ";
    location / {
        proxy_pass http://127.0.0.1:8000;
    }
}" >> flaskapp
service nginx restart
cd ~
cd /flask_application
gunicorn -b 0.0.0.0:8000 my_app:app