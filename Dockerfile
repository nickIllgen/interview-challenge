FROM python:3.9-alpine
WORKDIR /app
RUN apk update

EXPOSE 5000/tcp

COPY ./app/requirements.txt .
RUN pip3 install -r requirements.txt

COPY ./app/app.py .
# COPY ./app/helper.py .
CMD [ "python", "./app.py" ]