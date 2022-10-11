python3 -m pip install --upgrade pip
pip3 install boto3

echo "
python3 -m pip install --upgrade pip
pip install flask

echo \"
from flask import Flask
app = Flask(__name__)

@app.route('/')
def my_app():
    return 'First Flask Application!'
\" > app.py

python -m flask --app app run --port 8080
" > deployflask.sh


ECSImageId=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs*" --query 'sort_by(Images, &CreationDate)[].Name' --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)
# silently run instances
aws ec2 run-instances --image-id $ECSImageId --count 1 --instance-type t2.micro --key-name vockey --user-data file://deployflash.sh> /dev/null 2>&1

# terminate all instances
# aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" --output text)
