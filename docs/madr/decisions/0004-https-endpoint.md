# HTTPS endpoint

* Status: accepted

## Context and Problem Statement

Create https endpoint for the Flask API. Redirect http toward https

## Considered Options

* Load balancers

## Decision Outcome
Load balancers

HTTPS endpoint cannot terminate on an EC2 instance.  
HTTPS endpoint can terminate on an application load balancer (LB).  
Then connect application LB to an EC2 instance in two different availability zones.  
Use the same security group for the application LB and EC2 instances.  
Application LB cannot be connected to us-west-2a (there was a message on why when I tried to create it, but I forget what it said), so use us-west-2b and us-west-2c  
Listen to HTTPS Port 443 and forward traffic to EC2 instance on Port 80  
Listen to HTTP Port 80 and redirect to HTTPS Port 443

DNS A record cannot point toward an application LB.  
DNS A record can point toward a network LB.  
Network Load Balancer needs an IP address for every availability zone with an EC2 instance.  
Create two Elastic IP addresses to use for the 2 availability zones, put them in DNS A record  
Build network LB an associate one Elastic IP for each availability zone  
Target group for network LB toward application LB.  

See diagram of load balancer architecture at:
https://github.com/ej838639/lazarus/blob/LAZ-11_madr_load_balancers/diagrams/lazarus%20load%20balancers.excalidraw

Use Excalidraw to open it.  
https://excalidraw.com/