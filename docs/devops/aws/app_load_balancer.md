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
Select default, and add security group used by the instances

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
Variables
```shell
LOAD_BALANCER="lazarus-lb"
TARGET_GROUP="lazarus-group"

```

### Create an Application Load Balancer
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html

