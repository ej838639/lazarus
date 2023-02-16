FROM python:3.10
WORKDIR /usr/src/lazarus
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY server/ server/
EXPOSE 3000
CMD [ "waitress-serve", "--port=3000", "server.app:app" ]