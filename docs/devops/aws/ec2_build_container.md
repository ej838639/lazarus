# Create EC2 instance and build docker container

## Console
### Create EC2 instance
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html
Navigate to EC2 section  
In the middle of the page, click "Launch Instance" and select "Launch Instance"  
Key pair: without a key pair  
check Allow HTTP traffic

### Pull, build, and run docker container on EC2 instance
https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html
Click Connect to open the EC2 instance
```sh
sudo yum update -y  # ensure most recent packages installed on instance
sudo amazon-linux-extras install docker
sudo docker --version  # confirm docker installed
sudo service docker start
sudo docker info  # confirm docker service started
sudo usermod -a -G docker ec2-user # remove the need to use sudo before Docker commands
exit
```
Need to exit and reconnect for usermod change to take effect  
Close instance tab  
In Console, click Connect to open EC2 instance again
```sh
docker pull registry.hub.docker.com/ej838639/lazarus:1.7
docker images  # confirm image pulled
docker build -t ej838639/lazarus:1.7 .
docker run \
--name lazarus_1_7 \
-p 3000:3000 \
-e FLASK_ENV=production \
-d \
ej838639/lazarus:1.7 
docker ps  # confirm container running
exit
```

### Create inbound rule
Go to instances list, click on instance.  
Go to security tab (middle bottom of page)  
Click on Security group link  
Edit inbound rules  
Add rule  
Scroll down to last inbound rule. Leave it as Custom TCP. Port Range 3000.  
Leave it as 0.0.0.0/0 that allows any IPv4 inbound location

### Test endpoint
From console, collect the public IP. Combine with port and API endpoint.
http://35.92.132.81:3000/quiz_create

## CLI
If not already done, create access key and configure AWS CLI

Create access key for user
https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html

Configure AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
```shell
which aws  # should show /usr/local/bin/aws
aws configure  # enter credentials
```

### Create Key Pair
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html
Create an aws directory outside the project to store the key pair. cd into the dir
```shell
aws ec2 create-key-pair \
--key-name my-key-pair \
--query 'KeyMaterial' \
--output text > my-key-pair.pem

chmod 400 my-key-pair.pem
```

### Variables
```shell
SMALLEST_INSTANCE='t2.micro'
LINUX_OS='ami-06e85d4c3149db26a'
PROJECT='lazarus'
```

### Create Security Group
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-sg.html
(This was configured automatically in the console.)

Manually create Security Group
https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
```shell
SECURITY_GROUP=`aws ec2 create-security-group \
--group-name $PROJECT-sg \
--description "$PROJECT security group" \
--output text`

aws ec2 authorize-security-group-ingress \
--group-id $SECURITY_GROUP \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
--group-id $SECURITY_GROUP \
--ip-permissions IpProtocol=tcp,FromPort=3000,ToPort=3000,IpRanges="[{CidrIp=0.0.0.0/0,Description='Docker port for a Flask app'}]"

# if needed to set SECURITY_GROUP variable 
SECURITY_GROUP=`aws ec2 describe-security-groups \
--filters "Name=group-name,Values=$PROJECT-sg" \
--query "SecurityGroups[*].GroupId" \
--output text`

```

### Create EC2 instance
Launch instance
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-instances.html

Find an AMI
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
Use the same AMI recommended for Linux when creating the instance in the console
```shell
aws ec2 run-instances \
--image-id $LINUX_OS \
--count 1 \
--instance-type $SMALLEST_INSTANCE \
--key-name MyKeyPair \
--security-group-ids $SECURITY_GROUP \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$PROJECT}]"

# To update instance later
INSTANCE_ID=`aws ec2 describe-instances \
--filters "Name=tag:Name,Values=$PROJECT" "Name=instance-state-name,Values=running" \
--query "Reservations[*].Instances[*].InstanceId" \
--output text`

# For Public DNS to use for SSH
PUBLIC_DNS_NAME=`aws ec2 describe-instances \
--filters "Name=tag:Name,Values=$PROJECT" \
--query "Reservations[*].Instances[*].PublicDnsName" \
--output text`

# For Public IP address to use to access Flask app
PUBLIC_IP=`aws ec2 describe-instances \
--filters "Name=tag:Name,Values=$PROJECT" \
--query "Reservations[*].Instances[*].PublicIpAddress" \
--output text`

# hyperlink to run app
HYPERLINK="http://$PUBLIC_IP:3000/quiz_create"
echo $HYPERLINK

```

### SSH to EC2 instance
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html

```shell
chmod 400 my-key-pair.pem
ssh -i my-key-pair.pem ec2-user@$PUBLIC_DNS_NAME

# Now in EC2 instance
sudo yum update -y  # ensure most recent packages installed on instance
sudo amazon-linux-extras install docker -y # how avoid user input for yes?
sudo service docker start
sudo useradd docker_runner
sudo passwd -d docker_runner
sudo usermod -a -G docker docker_runner
su - docker_runner
docker pull registry.hub.docker.com/ej838639/lazarus:latest
docker run \
--name lazarus \
-p 3000:3000 \
-e FLASK_ENV=production \
-d \
ej838639/lazarus:latest

exit

# back at local prompt in aws directory
echo $HYPERLINK
# click on hyperlink to access api
```

### Terminate Instance and cleanup
When need to delete instance
```shell
aws ec2 terminate-instances \
--instance-ids $INSTANCE_ID

aws ec2 delete-security-group \
--group-name $SECURITY_GROUP
```

## Open Source Tools
Eventually building toward this:
https://aws.amazon.com/blogs/opensource/deploying-python-flask-microservices-to-aws-using-open-source-tools/

### Create Elastic Container Registry (ECR)

```shell
export REGION="us-west-2"
export AWS_ID="254394382277"
PROJECT="lazarus"
VERSION="latest"

# if not already done, create ECR repository
aws ecr create-repository \
--repository-name $PROJECT-app \
--image-scanning-configuration scanOnPush=true \
--region $REGION

aws ecr get-login-password \
--region $REGION | \
docker login \
--username AWS \
--password-stdin $AWS_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-app

```

### Push docker image to ECR
```shell
docker tag ej838639/$PROJECT:$VERSION $AWS_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-app:$VERSION
docker push $AWS_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-app:$VERSION

```

### Terraform
cd to terraform folder
```shell
terraform init # if not already initialized
terraform plan
terraform apply

```

### Testing
Click on hyperlink to confirm it is accessible.
