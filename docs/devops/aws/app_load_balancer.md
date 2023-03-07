# Deploy an Application Load Balancer (ALB)
Here are instructions to deploy an Application Load Balancer (ALB) for one EC2 instance per Availability Zone. Start with http endpoint and improve to use SSL certificates for an https endpoint.

The following assumes that there is an EC2 instance with the Lazarus app in Availability Zones us-west-2b and us-west-2c

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-getting-started.html
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

## Console

### Create Target Group for http endpoint
Create Target Group  
Instances  
lazarus-http-group  
HTTP: 80  
Default VPC  
HTTP1  
Tag: lazarus
Click Next

Select Availability Zones and instances with Lazarus app  
Click Include as Pending below  
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

### Test Load Balancer for http
In the EC2 section, in the bottom of the left navigation pain, in Load Balancing, click Target Groups.  
Click on the newly created load balancer.  
Wait until the "healthy" targets matches the "total targets". This may take a few minutes.

In the EC2 section, in the bottom of the left navigation pain, in Load Balancing, click on Load Balancers.  
Click on the newly created load balancer.  
In the Details section, copy the DNS Name and enter it in a web browser. The app should load.

### Create an HTTPS endpoint for the ALB
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html  
Use AWS Certificate Manager (ACM)  
https://aws.amazon.com/certificate-manager/  

#### Request Certificate
https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html

Navigate to ACM, click Request a Certificate  
Domain Name: sntxrr.org  
Defaults: validation method: DNS validation; key algorithm: RSA 2048  
Tag: lazarus  
Click Request  

The certificate is in the list. If not, click refresh.
From the link above:  
> A certificate enters status Pending validation upon being requested, unless it fails for any of the reasons given in the troubleshooting topic Certificate request fails. ACM makes repeated attempts to validate a certificate for 72 hours and then times out. If a certificate shows status Failed or Validation timed out, delete the request, correct the issue with DNS validation or Email validation, and try again. If validation succeeds, the certificate enters status Issued.

#### DNS Validation
https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html

Click on the certificate.  
Click Create Records in Route 53  
Click Create records  
> Your new certificate might continue to display a status of Pending validation for up to 30 minutes.

#### Create Target Group for https endpoint
In EC2, on the bottom left navigation, select Target Groups  
Click Create Target Group  
Instances  
lazarus-https-group  
HTTPS: 443  
Default VPC  
HTTP1  
Click Next  

Select Availability Zones and instances with Lazarus app  
Click Include as Pending below  
Click Create Target Group

#### Create an HTTPS Listener
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

Go to Load Balancers in EC2
Click on the Load Balancer
At the bottom in Listeners, click on "Add Listener"
Select HTTPS in the dropdown for Protocol
In default actions, select "Forward To"
In target group, select the https target group created for this ALB (ex: lazarus-https-lb)
Security policy: keep default
Default SSL/TLS Certificate: select the certificate created for this domain
Tags: lazarus
Click Add
In listeners, you will see an error for HTTPS:443. Complete the next step to fix this.

#### Update Security Group Rules
In the load balancer, click on the Security tab.
Click on the security group for this ALB
In the Inbound rules, click Edit inbound rules
At the bottom, click Add rule
In type, select HTTPS
Description: HTTPS for Docker container port for Flask app
Source: 0.0.0.0/0

#### Create http Target Group for Network Load Balancer
In EC2, in the bottom-left navigation, select Target Groups  
Create Target Group  
lazarus-network-lb-http-group
Port: 80
Health checks: http
tag: lazarus
Click Next

Application Load Balancer: lazarus-lb  
Click Create Load Balancer

#### Create https Target Group for Network Load Balancer
In EC2, in the bottom-left navigation, select Target Groups  
Create Target Group  
lazarus-network-lb-https-group
Port: 443
Health checks: https
tag: lazarus
Click Next

Application Load Balancer: lazarus-lb  
Click Create Load Balancer

#### Create Network Load Balancer
In EC2, in the bottom-left navigation, select Load Balancers  
Click Create load balancer  
Select Network Load Balancer  
lazarus-network-lb
Select the availability zones with the instances. Leave as Assigned by AWS  
TCP 80 Default Action: select group for http  
Click Add listener  
TCP 443 Default Action: select group for https
tag: lazarus

> It will take a few minutes to deploy.

### Route traffic from Route 53 to Network Load Balancer
https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html  

In Route 53, click on the hosted zone  
Delete any existing A record
Click Create Record  
Click the toggle for Alias
Route traffic to: Alias to Network Load Balancer
Region: us-west-2
Choose the network load balancer you created
Click Create Record

## CLI
Create an Application Load Balancer  
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html

Variables
```shell
PROJECT='lazarus2'
LOAD_BALANCER="${PROJECT}-lb"
TARGET_GROUP_ALB_HTTP="${PROJECT}-alb-http-group"
TARGET_GROUP_ALB_HTTPS="${PROJECT}-alb-https-group"
TARGET_GROUP_NLB_HTTP="${PROJECT}-nlb-http-group"
TARGET_GROUP_NLB_HTTPS="${PROJECT}-nlb-http-group"
REGION="us-west-2"
ZONE_B="${REGION}b"
ZONE_C="${REGION}c"

```

### Create http Target Group for ALB

```shell
VPC_ID=`aws ec2 describe-vpcs \
--filters "Name=is-default, Values=true" \
--query "Vpcs[*].VpcId" \
--output text`

aws elbv2 create-target-group \
--name $$TARGET_GROUP_ALB_HTTP \
--protocol HTTP \
--port 80 \
--vpc-id $VPC_ID \
--ip-address-type ipv4 \
--tags=${PROJECT}

TARGET_GROUP_ARN_ALB_HTTP=`aws elbv2 describe-target-groups \
--names $TARGET_GROUP_ALB_HTTP \
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
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTP  \
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

LOAD_BALANCER_ARN_ALB=`aws elbv2 describe-load-balancers \
--names ${LOAD_BALANCER} \
--query "LoadBalancers[*].LoadBalancerArn" \
--output text`

LOAD_BALANCER_DNS_NAME=`aws elbv2 describe-load-balancers \
--names ${LOAD_BALANCER} \
--query "LoadBalancers[*].DNSName" \
--output text`

aws elbv2 create-listener \
--load-balancer-arn $LOAD_BALANCER_ARN_ALB \
--protocol HTTP \
--port 80  \
--default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN_ALB_HTTP

```

### Check the ALB health

```shell
INSTANCE_B_HEALTH=`aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTP \
--targets Id=$INSTANCE_ID_B \
--query "TargetHealthDescriptions[*].TargetHealth.State" \
--output text`

INSTANCE_C_HEALTH=`aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTP \
--targets Id=$INSTANCE_ID_C \
--query "TargetHealthDescriptions[*].TargetHealth.State" \
--output text`

TARGET_GROUP_ARN_ALB_HTTP=`aws elbv2 describe-target-groups \
--names lazarus-group \
--query "TargetGroups[*].TargetGroupArn" \
--output text`

aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTP \
--targets Id=$INSTANCE_ID_B \
--query "TargetHealthDescriptions[*].TargetHealth.State" \
--output text

TARGET_GROUP_ARN_ALB_HTTPS=`aws elbv2 describe-target-groups \
--names lazarus-http-group \
--query "TargetGroups[*].TargetGroupArn" \
--output text`

aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTPS \
--targets Id=$INSTANCE_ID_B \
--query "TargetHealthDescriptions[*].TargetHealth.State" \
--output text

aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTPS \
--targets Id=$INSTANCE_ID_B

aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTPS \
--targets Id=$INSTANCE_ID_C \
--query "TargetHealthDescriptions[*].TargetHealth.State" \
--output text

aws elbv2 describe-target-health \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTPS \
--targets Id=$INSTANCE_ID_C

```
Troubleshoot Health Check fails  
https://aws.amazon.com/premiumsupport/knowledge-center/elb-fix-failing-health-checks-alb/  
https://aws.amazon.com/premiumsupport/knowledge-center/elb-alb-troubleshoot-502-errors/
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html

Bucket policy
elb-account-id: US West (Oregon) – 797873946194
AWS Account ID: 254394382277
Bucket name: ej838639-lazarus-access-logs
```shell

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::elb-account-id:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::bucket-name/prefix/AWSLogs/your-aws-account-id/*"
    }
  ]
}

```

```shell
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::797873946194:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::ej838639-lazarus-access-logs/prefix/AWSLogs/254394382277/*"
    }
  ]
}
```

### Request an SSL certificate
https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html#request-public-cli
https://docs.aws.amazon.com/cli/latest/reference/acm/list-certificates.html

### Request Certificate and Validate with DNS
```shell
aws acm request-certificate \
--domain-name $DOMAIN \
--key-algorithm RSA_2048 \
--validation-method DNS \
--idempotency-token 1234 \
--options CertificateTransparencyLoggingPreference=DISABLED \
--tags lazarus

CERTIFICATE_ARN=`aws acm list-certificates \
--query "CertificateSummaryList[*].CertificateArn" \
--output text`



```

### Add ALB HTTPS Target Group and Listener
See "Add an HTTPS listener" section of:
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html
https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-listener.html
https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-rule.html

```shell
aws elbv2 create-target-group \
--name $TARGET_GROUP_ALB_HTTPS \
--protocol HTTPS \
--port 443 \
--vpc-id $VPC_ID \
--ip-address-type ipv4 \
--tags=${PROJECT}

TARGET_GROUP_ARN_ALB_HTTPS=`aws elbv2 describe-target-groups \
--names $TARGET_GROUP_ALB_HTTPS \
--query "TargetGroups[*].TargetGroupArn" \
--output text`

aws elbv2 create-listener \
--load-balancer-arn $LOAD_BALANCER_ARN_ALB \
--protocol HTTPS \
--port 443  \
--certificates CertificateArn=$CERTIFICATE_ARN \
--default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ALB_HTTPS


```

### Create a Network Load Balancer
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/network-load-balancer-cli.html  

```shell


```

### Route 53 add record toward Network Load Balancer

```shell


```