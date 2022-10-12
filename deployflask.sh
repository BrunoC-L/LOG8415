#!/bin/bash
apt-get update
apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y python3-venv
mkdir flask_application && cd flask_application
python3 -m venv venv
source venv/bin/activate
pip install Flask
echo "from flask import Flask
app = Flask(__name__)

@app.route('/')
def my_app():
    return 'First Flask Application'" > my_app.py
export flask_application=my_app.py
flask run --host=0.0.0.0 --port=80