#!/bin/bash
apt-get update
apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y gunicorn3 
apt-get install -y python3-venv

mkdir flask_application
cd flask_application
python3 -m venv venv
source venv/bin/activate
pip install flask
echo "from flask import Flask
app = Flask(__name__)
@app.route('/')
def my_app():
    return 'First Flask Application'
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