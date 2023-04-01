# DNS A record

* Status: accepted

## Context and Problem Statement

Determine the DNS A record to use in the hosted zone

## Considered Options

* Elastic IP address
* Alias traffic to load balancer

## Decision Outcome
Elastic IP address

When creating the DNS A record, there is an option to Alias traffic to the network load balancer.  
Using the Alias more clearly indicates the destination is a load balancer, but it abstracts how this is done.    
Desire to learn infrastructure setup, so want to avoid abstraction.
Minimize A record changes to DNS zone since it may take a few hours to propagate.  
However it costs a dollar per day for unused Elastic IP addresses, so I will delete them when not using the infrastructure, so avoiding propagation time is not a factor in the decision.   
Use Elastic IP address since it is more basic method for A records even though I have to delete them anyway (when I destroy infrastructure) to minimize costs. 