# Docker commands

## Development

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
-t ej838639/lazarus:latest \
-t ej838639/lazarus:1.7 \
--platform linux/amd64 \ # only needed if building from a mac
.

docker run \
--name lazarus \
-p 3000:3000 \
-e FLASK_ENV=development \
-d \
ej838639/lazarus:latest
```

http://localhost:3000/quiz_create

## Production

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
-t ej838639/lazarus:1.8 \
.

docker run \
--name lazarus_1_8 \
-p 3000:3000 \
-d \
ej838639/lazarus:1.8

```
