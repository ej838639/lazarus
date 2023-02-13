# Docker commands

## Docker build
Create with version number to clearly show version used for latest
```shell
docker build \
-t ej838639/lazarus:latest \
-t ej838639/lazarus:1.7 \
--platform linux/amd64 \ # only needed if building from a mac
.

```

## Docker run

Development
```shell
docker run \
--name lazarus_latest \
-p 3000:3000 \
-e FLASK_ENV=development \
-d \
ej838639/lazarus:latest

```
http://localhost:3000/quiz_create

Production
```shell
docker run \
--name lazarus_latest \
-p 3000:3000 \
-e FLASK_ENV=production \
-d \
ej838639/lazarus:latest

```

## Docker push
```shell
docker login
docker push ej838639/lazarus:1.7
docker push ej838639/lazarus:latest

```