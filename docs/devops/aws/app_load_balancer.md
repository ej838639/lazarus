# Deploy an Application Load Balancer (ALB)
Here are instructions to deploy an Application Load Balancer (ALB) for one EC2 instance per Availability Zone. Start with http endpoint and improve to use SSL certificates for an https endpoint.

The following assumes that there is an EC2 instance with the Lazarus app in Availability Zones us-west-2b and us-west-2c

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-getting-started.html
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

## Console

### Create Target Group

Create Target Group (opens a new tab)
Instances
lazarus-group
HTTP
80
Default VPC
HTTP1

Register targets
Select Availability Zones and instances with Lazarus app
Click Create Target Group

### Create Application Load Balancer
Load Balancer Name: lazarus-lb

Keep Defaults:
Internet-facing
IPv4
Default VPC

Mappings: 
us-west-2b, default subnet
us-west-2c, default subnet

Security groups
Add security group used by the instances

Listeners and Routing
Keep defaults: HTTP, Port 80
Select target group created

Tags: lazarus

Click Create Load Balancer

### Test Load Balancer
In the EC2 section, in the bottom of the left navigation pain, in Load Balancing, click Target Groups.
Click on the newly created load balancer.
Wait until the "healthy" targets matches the "total targets". This may take a few minutes.

In the EC2 section, in the bottom of the left navigation pain, in Load Balancing, click on Load Balancers.
Click on the newly created load balancer.
In the Details section, copy the DNS Name and enter it in a web browser. The app should load.

### Create Certificate
Use AWS Certificate Manager (ACM)
https://aws.amazon.com/certificate-manager/

## CLI
Create an Application Load Balancer
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html

Variables
```shell
PROJECT='lazarus2'
LOAD_BALANCER="${PROJECT}-lb"
TARGET_GROUP="${PROJECT}-group"
REGION="us-west-2"
ZONE_B="${REGION}b"
ZONE_C="${REGION}c"

```

### Create Target Group

```shell
VPC_ID=`aws ec2 describe-vpcs \
--filters "Name=is-default, Values=true" \
--query "Vpcs[*].VpcId" \
--output text`

aws elbv2 create-target-group \
--name $TARGET_GROUP \
--protocol HTTP \
--port 80 \
--vpc-id $VPC_ID \
--ip-address-type ipv4 \
--tags=${PROJECT}

TARGET_GROUP_ARN=`aws elbv2 describe-target-groups \
--names lazarus-group \
--query "TargetGroups[*].TargetGroupArn" \
--output text`

INSTANCE_ID_B=`aws ec2 describe-instances \
--filters "Name=tag:Name, Values=${PROJECT}" "Name=availability-zone, Values=${ZONE_B}" \
--query "Reservations[*].Instances[*].InstanceId" \
--output text`

INSTANCE_ID_C=`aws ec2 describe-instances \
--filters "Name=tag:Name, Values=${PROJECT}" "Name=availability-zone, Values=${ZONE_C}" \
--query "Reservations[*].Instances[*].InstanceId" \
--output text`

aws elbv2 register-targets \
--target-group-arn $TARGET_GROUP_ARN  \
--targets Id=$INSTANCE_ID_B Id=$INSTANCE_ID_C

```

### Create an Application Load Balancer

```shell
SUBNET_B=`aws ec2 describe-subnets \
--filter "Name=availability-zone, Values=${ZONE_B}" "Name=default-for-az, Values=true" \
--query "Subnets[*].SubnetId" \
--output text`

SUBNET_C=`aws ec2 describe-subnets \
--filter "Name=availability-zone, Values=${ZONE_C}" "Name=default-for-az, Values=true" \
--query "Subnets[*].SubnetId" \
--output text`

SECURITY_GROUP=`aws ec2 describe-security-groups \
--filters "Name=group-name,Values=$PROJECT-sg" \
--query "SecurityGroups[*].GroupId" \
--output text`

aws elbv2 create-load-balancer \
--name ${LOAD_BALANCER} \
--subnets $SUBNET_B $SUBNET_C \
--security-groups $SECURITY_GROUP

LOAD_BALANCER_ARN=`aws elbv2 describe-load-balancers \
--names ${LOAD_BALANCER} \
--query "LoadBalancers[*].LoadBalancerArn" \
--output text`

LOAD_BALANCER_DNS_NAME=`aws elbv2 describe-load-balancers \
--names ${LOAD_BALANCER} \
--query "LoadBalancers[*].DNSName" \
--output text`

aws elbv2 create-listener \
--load-balancer-arn $LOAD_BALANCER_ARN \
--protocol HTTP \
--port 80  \
--default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

```

### Check the ALB health

```shell
INSTANCE_B_HEALTH=`aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN \
--targets Id=$INSTANCE_ID_B \
--query "TargetHealthDescriptions[*].TargetHealth.State" \
--output text`

INSTANCE_C_HEALTH=`aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN \
--targets Id=$INSTANCE_ID_C \
--query "TargetHealthDescriptions[*].TargetHealth.State" \
--output text`

```
