FROM python:3.9-alpine

RUN apk update

EXPOSE 5000/tcp
WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY app.py .

CMD [ "python", "./app.py" ]