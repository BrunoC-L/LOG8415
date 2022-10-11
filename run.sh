python3 -m pip install --upgrade pip
pip3 install boto3

# aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs*" --query 'sort_by(Images, &CreationDate)[].Name' --query 'sort_by(Images, &CreationDate)[-1].Name'
# test=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs*" --query 'sort_by(Images, &CreationDate)[].Name' --query 'sort_by(Images, &CreationDate)[-1].Name')

ECSImageId=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs*" --query 'sort_by(Images, &CreationDate)[].Name' --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)
# silently run instances
aws ec2 run-instances --image-id $ECSImageId --count 4 --instance-type t2.micro --key-name vockey > /dev/null 2>&1

# terminate all instances
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId]" --output text)
