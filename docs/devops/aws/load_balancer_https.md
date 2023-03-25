# Deploy Load Balancers for a https endpoint 
Here are instructions to deploy a https endpont using a Network Load Balancer (NLB) and an Application Load Balancer (ALB) for one EC2 instance per Availability Zone.

The following assumes that there is an EC2 instance with the Lazarus app in Availability Zones us-west-2b and us-west-2c

https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-getting-started.html
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

## Console

### Create Elastic IP Address
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html#using-instance-addressing-eips-allocating

Create a static Elastic IP address for every availability zone where an EC2 instance is deployed  
This configuration has an instance in two availability zones, so we will create two Elastic IPs  

In EC2, in bottom-left of navigation, in Network & Security, choose Elastic IPs  
Click Allocate Elastic IP  
Network Border Group: region with instances and load balancers
Keep other defaults
Tags: lazarus
Click Allocate

Create a second Elastic IP address in the same way

### Route traffic from Route 53 to Elastic IPs
https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html  

Create DNS records to route traffic toward these Elastic IPs
Later we will enter these Elastic IPs in the Network Load Balancer

In Route 53, click on the hosted zone  
Delete any existing A record
Click Create Record  
Enter the Elastic IP Addresses (multiple values on separate lines) 
Click Create Records

> It may take a few hours for the records to propagate. In the meantime, continue with the following instructions

### Request Certificate
Use AWS Certificate Manager (ACM)  
https://aws.amazon.com/certificate-manager/  
https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html  

Navigate to ACM, click Request a Certificate  
Domain Name: sntxrr.org  
Defaults: validation method: DNS validation; key algorithm: RSA 2048  
Tag: lazarus  
Click Request  

The certificate is in the list. If not, click refresh.
From the link above:  
> A certificate enters status Pending validation upon being requested, unless it fails for any of the reasons given in the troubleshooting topic Certificate request fails. ACM makes repeated attempts to validate a certificate for 72 hours and then times out. If a certificate shows status Failed or Validation timed out, delete the request, correct the issue with DNS validation or Email validation, and try again. If validation succeeds, the certificate enters status Issued.

### DNS Validation
https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html

Click on the certificate.  
Click Create Records in Route 53  
Click Create records  
> Your new certificate might continue to display a status of Pending validation for up to 30 minutes.

### Create HTTP Target Group
Great Target Group to forward traffic to Port 80 on the EC2 instance

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

Click on the Target Group 
Check for when "healthy" targets matches the "total targets". This may take a few minutes.  
Continue the following steps while you wait.  
If the targets are "unhealthy", see the troubleshooting section below.

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
HTTPS, Port 443, in Forward to, select http target group created
Click Add listener
HTTP, Port 80, Default Action: redirect to HTTP

Secure Listener
Keep default Security Policy
Default SSL/TLS: From ACM, select certificate created

Tags: lazarus

Click Create Load Balancer

### Create TCP Port 80 Target Group for Network Load Balancer
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-network-load-balancer.html

In EC2, in the bottom-left navigation, select Target Groups  
Create Target Group  
Basic Configuration: Target Type: Application Load Balancer  
Target Group Name: lazarus-prod-network-lb-http-group  
Protocol: TCP (default)  
Port: 80  
Health checks: HTTP   
tag: lazarus  
Click Next

Application Load Balancer: lazarus-prod-lb  
Click Create Target Group

### Create TCP Port 443 Target Group for Network Load Balancer
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-network-load-balancer.html
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/application-load-balancer-target.html

In EC2, in the bottom-left navigation, select Target Groups  
Create Target Group  
Basic Configuration: Target Type: Application Load Balancer  
Target Group Name: lazarus-network-lb-https-group  
Protocol: TCP (default)  
Port: 443  
Health checks: HTTPS  
tag: lazarus  
Click Next

Application Load Balancer: lazarus-lb  
Click Create Load Balancer

### Create Network Load Balancer
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-network-load-balancer.html
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/application-load-balancer-target.html

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

### Test the https endpoint
Check if the DNS record propagated and the SSL certificate propagated (see above in those sections).

Test the https endpoint.
https://sntxrr.org

If necessary, see the troubleshooting section below

### Delete configuration
When ready, delete the configuration

If you also want to cleanup the 'A' records in DNS:
Navigate to the hosted zone in Route 53
Add the new A records and ensure they propagate before deleting the others
Check the A records to delete and click Delete record

Navigate to Load Balancers in EC2   
Click on the network load balancer. In actions, select Delete load balancer    
Click on the application load balancer.  
In the listeners, delete the HTTP listener, andn then the HTTPS listener  
In actions, select Delete load balancer  

Navigate to Target Groups in EC2  
Click on the target group. In actions, select delete  

## CLI
Create an Application Load Balancer  
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html

Variables
```shell
PROJECT='lazarus-prod'
DOMAIN="sntxrr.org"
REGION="us-west-2"
ZONE_B="${REGION}b"
ZONE_C="${REGION}c"
HOSTED_ZONE_ID="Z05234763LM5P4JGVQ78Q"
DNS_RECORD_CREATE_FILENAME="file://dns_create.json"
LOAD_BALANCER_NAME_ALB="${PROJECT}-lb"
LOAD_BALANCER_NAME_NLB="${PROJECT}-network-lb"
TARGET_GROUP_ALB_HTTP="${PROJECT}-alb-http-group"
TARGET_GROUP_NLB_HTTP="${PROJECT}-nlb-http-group"
TARGET_GROUP_NLB_HTTPS="${PROJECT}-nlb-https-group"

```

### Create Elastic IPs

ELASTIC_IP_B="44.233.103.55"
ELASTIC_IP_C="54.214.70.170"

```shell
aws ec2 allocate-address \
--tag-specifications "ResourceType=elastic-ip,Tags=[{Key=lazarus,Value=lazarus},{Key=zone_a,Value=zone_a}]"

ELASTIC_ALLOCATION_ID_B=`aws ec2 describe-addresses \
--filters "Name=tag-key, Values=zone_b" \
--query "Addresses[*].AllocationId" \
--output text`

ELASTIC_ALLOCATION_ID_C=`aws ec2 describe-addresses \
--filters "Name=tag-key, Values=zone_c" \
--query "Addresses[*].AllocationId" \
--output text`

```

### Route 53 add record with Elastic IPs
https://aws.amazon.com/premiumsupport/knowledge-center/simple-resource-record-route53-cli/

Create a json file with the following format. Enter the domain and Elastic IP addresses  
```shell
{
  "Comment": "CREATE a record ",
  "Changes": [{
    "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "sntxrr.org",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "44.233.103.55"}, { "Value": "54.214.70.170"}]
      }
    }
  ]
}

```

Navigate to aws_cli_files and run the following:
```shell
aws route53 change-resource-record-sets \
--hosted-zone-id $HOSTED_ZONE_ID \
--change-batch $DNS_RECORD_CREATE_FILENAME

```

### Request an SSL certificate
https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html#request-public-cli
https://docs.aws.amazon.com/cli/latest/reference/acm/list-certificates.html

```shell
aws acm request-certificate \
--domain-name $DOMAIN \
--key-algorithm RSA_2048 \
--validation-method DNS \
--idempotency-token 1234 \
--options CertificateTransparencyLoggingPreference=DISABLED \
--tags $PROJECT

CERTIFICATE_ARN=`aws acm list-certificates \
--query "CertificateSummaryList[*].CertificateArn" \
--output text`



```

### Create http Target Group for ALB

```shell
VPC_ID=`aws ec2 describe-vpcs \
--filters "Name=is-default, Values=true" \
--query "Vpcs[*].VpcId" \
--output text`

aws elbv2 create-target-group \
--name $TARGET_GROUP_ALB_HTTP \
--protocol HTTP \
--port 80 \
--vpc-id $VPC_ID \
--ip-address-type ipv4 \
--tags "Key=$PROJECT"

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
--name ${LOAD_BALANCER_NAME_ALB} \
--subnets $SUBNET_B $SUBNET_C \
--security-groups $SECURITY_GROUP \
--tags "Key=$PROJECT"

LOAD_BALANCER_ARN_ALB=`aws elbv2 describe-load-balancers \
--names ${LOAD_BALANCER_NAME_ALB} \
--query "LoadBalancers[*].LoadBalancerArn" \
--output text`

LOAD_BALANCER_DNS_NAME_ALB=`aws elbv2 describe-load-balancers \
--names ${LOAD_BALANCER_NAME_ALB} \
--query "LoadBalancers[*].DNSName" \
--output text`

```

### ALB Create https listener toward http target group
See "Add an HTTPS listener" section of:
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html
https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-listener.html
https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-rule.html

Create a https listener on the Application Load Balancer that forwards traffic to http on the EC2 instance
```shell
CERTIFICATE_ARN=`aws acm list-certificates \
--query "CertificateSummaryList[*].CertificateArn" \
--output text`

# https traffic forward to http target group
aws elbv2 create-listener \
--load-balancer-arn $LOAD_BALANCER_ARN_ALB \
--protocol HTTPS \
--port 443  \
--certificates CertificateArn=$CERTIFICATE_ARN \
--default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN_ALB_HTTP

# redirect http to https
aws elbv2 create-listener \
--load-balancer-arn $LOAD_BALANCER_ARN_ALB \
--protocol HTTP \
--port 80  \
--default-actions "Type=redirect,RedirectConfig={Protocol=HTTPS,Port=443,StatusCode=HTTP_301}"

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

```

### Create a Network Load Balancer
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/network-load-balancer-cli.html  
https://docs.aws.amazon.com/elasticloadbalancing/latest/network/application-load-balancer-target.html

```shell
ELASTIC_ALLOCATION_ID_B=`aws ec2 describe-addresses \
--filters "Name=tag-key, Values=zone_b" \
--query "Addresses[*].AllocationId" \
--output text`

ELASTIC_ALLOCATION_ID_C=`aws ec2 describe-addresses \
--filters "Name=tag-key, Values=zone_c" \
--query "Addresses[*].AllocationId" \
--output text`

aws elbv2 create-load-balancer \
--name $LOAD_BALANCER_NAME_NLB \
--type network \
--subnet-mappings SubnetId=$SUBNET_B,AllocationId=$ELASTIC_ALLOCATION_ID_B SubnetId=$SUBNET_C,AllocationId=$ELASTIC_ALLOCATION_ID_C \
--tags "Key=$PROJECT"

LOAD_BALANCER_ARN_NLB=`aws elbv2 describe-load-balancers \
--names ${LOAD_BALANCER_NAME_NLB} \
--query "LoadBalancers[*].LoadBalancerArn" \
--output text`

aws elbv2 create-target-group \
--name $TARGET_GROUP_NLB_HTTP \
--target-type alb \
--protocol TCP \
--port 80 \
--vpc-id $VPC_ID \
--health-check-protocol HTTP \
--tags "Key=$PROJECT"

TARGET_GROUP_ARN_NLB_HTTP=`aws elbv2 describe-target-groups \
--names $TARGET_GROUP_NLB_HTTP \
--query "TargetGroups[*].TargetGroupArn" \
--output text`

aws elbv2 create-target-group \
--name $TARGET_GROUP_NLB_HTTPS \
--target-type alb \
--protocol TCP \
--port 443 \
--vpc-id $VPC_ID \
--health-check-protocol HTTPS \
--tags "Key=$PROJECT"

TARGET_GROUP_ARN_NLB_HTTPS=`aws elbv2 describe-target-groups \
--names $TARGET_GROUP_NLB_HTTPS \
--query "TargetGroups[*].TargetGroupArn" \
--output text`

aws elbv2 register-targets \
--target-group-arn $TARGET_GROUP_ARN_NLB_HTTP  \
--targets Id=$LOAD_BALANCER_ARN_ALB

aws elbv2 register-targets \
--target-group-arn $TARGET_GROUP_ARN_NLB_HTTPS  \
--targets Id=$LOAD_BALANCER_ARN_ALB

aws elbv2 create-listener \
--load-balancer-arn $LOAD_BALANCER_ARN_NLB \
--protocol TCP \
--port 80  \
--default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN_NLB_HTTP \
--tags "Key=$PROJECT"

aws elbv2 create-listener \
--load-balancer-arn $LOAD_BALANCER_ARN_NLB \
--protocol TCP \
--port 443  \
--default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN_NLB_HTTPS \
--tags "Key=$PROJECT"

```

### Test the https endpoint
Check if the DNS record propagated and the SSL certificate propagated (see above in those sections).

Test the https endpoint.
https://sntxrr.org

If necessary, see the troubleshooting section below

### Delete configuration
When ready, delete the configuration

```shell
aws elbv2 delete-load-balancer \
--load-balancer-arn $LOAD_BALANCER_ARN_NLB

aws elbv2 delete-target-group \
--target-group-arn $TARGET_GROUP_ARN_NLB_HTTP

aws elbv2 delete-target-group \
--target-group-arn $TARGET_GROUP_ARN_NLB_HTTPS

aws elbv2 delete-load-balancer \
--load-balancer-arn $LOAD_BALANCER_ARN_ALB

aws elbv2 delete-target-group \
--target-group-arn $TARGET_GROUP_ARN_ALB_HTTP
```

## Check if DNS Registered

Check if dig shows the Elastic IP addresses in Route 53
```sh
dig sntxrr.org

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> sntxrr.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 53353
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;sntxrr.org.                    IN      A

;; ANSWER SECTION:
sntxrr.org.             1800    IN      A       192.64.119.252

;; Query time: 139 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Tue Feb 14 14:54:45 PST 2023
;; MSG SIZE  rcvd: 55


```

## Troubleshoot

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

## Terraform
Import SSL certificate
```shell
terraform import aws_acm_certificate.cert arn:aws:acm:us-west-2:254394382277:certificate/17710933-2ac8-4393-b004-73a37e8100fb

```