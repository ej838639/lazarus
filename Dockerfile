FROM python:3.10
WORKDIR /usr/src/lazarus
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY server/ server/
ENV FLASK_ENV=development
ENV FLASK_APP=server/app
ENV PORT=5000
EXPOSE 5000
CMD [ "python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5000" ]