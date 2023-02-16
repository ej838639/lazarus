# Lazarus Project
Learn DevOps by creating and deploying an app. 

**Primary Goal:** Learn how to use DevOps tools and processes.  
**Means to Achieve the Goal**: Build a quiz-creation API. 

Let's work together to build out the devops infrastructure for this app! Contact eric.johnson838639@gmail.com if you want to collaborate on this project.

See docs folder for DevOps details and Markdown Any Decision Records (MADR), aka Architectural Decision Records (ADR).

## Learning Objectives
### DevOps Tools Practice
Over-build solution to learn DevOps tools. Implement multiple approaches to every stage of the pipeline to gain experience and understand pros/cons. Automate everything to make it easier to adapt the tool to use at every stage.

### Create Quiz-Creation App
App to easily turn training material into a quiz on your favorite quiz platform. Create questions from key points in training. 

## How to run the app on your computer
Run with a Docker container or run in Python.
### Pull and run Docker container 
Install Docker and then run the following commands.
```shell
docker pull registry.hub.docker.com/ej838639/lazarus:latest
docker run \
--name lazarus \
-p 3000:3000 \
-d \
ej838639/lazarus:latest

```
Click on the following link to run the app
http://localhost:3000/quiz_create

### Clone repository and run Flask API in Python
Install Python 3.10.6. No validation done to determine if it may run on earlier Python versions, but you are welcome to try older versions before upgrading.
Navigate to a folder where you want to put the project.
```shell
git clone https://github.com/ej838639/lazarus.git
export FLASK_APP=app.py
export FLASK_ENV=development
cd lazarus/server
flask run --host=localhost --port=3000

```
Click on the following link to run the app
http://localhost:3000/quiz_create

## Docs
[Specification](https://github.com/ej838639/lazarus/blob/main/docs/spec.md)  
[Build Docker Container](https://github.com/ej838639/lazarus/blob/main/docs/devops/docker/docker.md)  
[Create AWS EC2 Instance](https://github.com/ej838639/lazarus/blob/main/docs/devops/aws/ec2_build_container.md)  

## Issues or Requests
Submit at https://github.com/ej838639/lazarus/issues