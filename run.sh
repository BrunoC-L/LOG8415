# open this as raw copy url and run `curl <url> > run.sh && sh run.sh`
python3 -m pip install --upgrade pip
pip3 install boto3

printf "python3 -m pip install --upgrade pip \npip install flask \nprintf \"from flask import Flask\\napp = Flask(__name__)\\n@app.route('/')\\ndef my_app():\\n  return 'app'\" > app.py\napp.py flask run --port 8080\n" > deployflask.sh

ECSImageId=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs*" --query 'sort_by(Images, &CreationDate)[].Name' --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)

SecurityGroup=$(aws ec2 create-security-group --description "Flask Group" --group-name flask-group --output text)
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type t2.micro --security-group-ids $SecurityGroup --key-name vockey --user-data file://deployflask.sh --query "Instances[].[InstanceId]" --output text

# terminate all instances
# aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" --output text)
