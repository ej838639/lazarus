FROM python:3.10
WORKDIR /usr/src/lazarus
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY server/ server/
EXPOSE 80
CMD [ "waitress-serve", "--port=80", "server.app:app" ]