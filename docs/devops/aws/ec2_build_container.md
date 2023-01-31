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
```shell
aws ec2 create-key-pair \
--key-name MyKeyPair \
--query 'KeyMaterial' \
--output text > MyKeyPair.pem

chmod 400 MyKeyPair.pem
```

### Create Security Group
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-sg.html
(This was configured automatically in the console.)

Manually create Security Group
https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
```shell
aws ec2 create-security-group \
--group-name lazarus-sg \
--description "lazarus security group"
# Output -> GroupId: sg-0667570fe7ab6ac45
# launch wizard: sg-03c5a8fee7b3b5813

# find your IP address
curl https://checkip.amazonaws.com
# Output -> 172.56.105.166

aws ec2 authorize-security-group-ingress \
--group-id sg-0667570fe7ab6ac45 \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
--group-id sg-0667570fe7ab6ac45 \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
--group-id sg-0667570fe7ab6ac45 \
--ip-permissions IpProtocol=tcp,FromPort=3000,ToPort=3000,IpRanges="[{CidrIp=0.0.0.0/0,Description='Docker port for a Flask app'}]"
```

### Create EC2 instance
Launch instance
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-instances.html

Find an AMI
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
Use the same AMI recommended for Linux when creating the instance in the console
```shell
aws ec2 run-instances \
--image-id ami-06e85d4c3149db26a \
--count 1 \
--instance-type t2.micro \
--key-name MyKeyPair \
--security-group-ids sg-0667570fe7ab6ac45
# Instance ID: i-0333aa35bf9cf5d98
```

### SSH to EC2 instance
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html
How obtain Public DNS from CLI? ec2-52-13-102-212.us-west-2.compute.amazonaws.com
```shell
ssh -i MyKeyPair.pem ec2-user@ec2-52-13-102-212.us-west-2.compute.amazonaws.com
ssh ec2-user@ec2-52-13-102-212.us-west-2.compute.amazonaws.com

# Now in EC2 instance
sudo yum update -y  # ensure most recent packages installed on instance
sudo amazon-linux-extras install docker # how avoid user input for yes?
sudo service docker start
sudo docker pull registry.hub.docker.com/ej838639/lazarus:1.7
sudo docker build -t ej838639/lazarus:1.7 .
sudo docker run \
--name lazarus_1_7 \
-p 3000:3000 \
-e FLASK_ENV=production \
-d \
ej838639/lazarus:1.7 
docker ps  # confirm container running
```