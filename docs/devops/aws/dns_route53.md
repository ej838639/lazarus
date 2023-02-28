# Create DNS Route 53 mapping
The following describes how to create a DNS record to route traffic from the Route 53 Hosted Zone to an IP address.

## Console

### Create Hosted Zone
Collect the domain and the IP address that you want DNS to route toward

Go to Route 53
Click Create Hosted Zone
Enter the domain (Ex: sntxrr.org)
Public Hosted
Click Create

### Create DNS record
Click on the Hosted Zone
Click Create Record
Keep default record type (A)
Enter the IP address
Keep default TTL as 300 seconds
Click Create Record

### Test
Enter the domain in a browser and check if it routes to the app. It usually takes a few hours, but it could take up to 72 hours. 


