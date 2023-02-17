# Docker commands
Here is the Dockerfile and Docker commands to use for development and production.
## Development
Dockerfile and commands to run in Development mode
### Dockerfile
```shell
FROM python:3.10  
WORKDIR /usr/src/lazarus  
COPY requirements.txt .  
RUN pip install -r requirements.txt  
COPY server/ server/  
ENV FLASK_APP=server/app  
ENV PORT=3000  
EXPOSE 3000  
CMD [ "python", "-m", "flask", "run", "--host=0.0.0.0", "--port=3000" ]

```

## Docker build and run

```shell
docker build \
-t ej838639/lazarus:1.7 \
--platform linux/amd64 \ # only needed if building from a mac
.

docker run \
--name lazarus \
-p 3000:3000 \
-e FLASK_ENV=development \
-d \
ej838639/lazarus:latest

docker login
docker push ej838639/lazarus:1.7
docker push ej838639/lazarus:latest
```

http://localhost:3000/quiz_create

## Production
Dockerfile and commands to run in production mode. This is what is used to build the EC2 instances.
### Dockerfile
```shell
FROM python:3.10
WORKDIR /usr/src/lazarus
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY server/ server/
EXPOSE 3000
CMD [ "waitress-serve", "--port=3000", "server.app:app" ]

```
### Docker build and run
```shell
docker build \
-t ej838639/lazarus:latest \
-t ej838639/lazarus:1.9 \
--platform linux/amd64 \
.

docker run \
--name lazarus_1_9 \
-p 3000:3000 \
-d \
ej838639/lazarus:1.9

docker login
docker push ej838639/lazarus:1.9
docker push ej838639/lazarus:latest

```
