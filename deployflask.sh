#!/bin/bash
apt-get update
apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y nginx
apt-get install -y gunicorn3 

mkdir flask_application && cd flask_application
pip install Flask
echo "from flask import Flask
app = Flask(__name__)
@app.route('/')
def my_app():
    return 'First Flask Application'
if __name__=='__main__':
    app.run(host='0.0.0.0', port=8080)" > my_app.py

cd etc/nginx/
cd sites-enabled/
echo "server {
    listen 80;
    server_name instance_public_ip;

    location / {
        proxy_pass http://127.0.0.1:8000;
    }
}" > flaskapp
service nginx restart
cd ~
cd flask_application
gunicorn3 my_app:my_app