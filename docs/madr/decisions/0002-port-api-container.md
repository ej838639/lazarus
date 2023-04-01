# Port for API and container

* Status: accepted

## Context and Problem Statement

Choose a port for the Flask API and a port for the Docker container

## Considered Options

* Port 3000
* Port 80

## Decision Outcome
Port 80 for Flask API port and exposed container port

Using a container in AWS it is helpful to have a root endpoint with no port needed.  
Use http to the container in AWS. So want container to use Port 80.  
It did not work to use Port 3000 on the Flask API and then Port 80 on the exposed port for the container.  
So use 80 for both.  
