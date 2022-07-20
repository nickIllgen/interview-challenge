FROM python:3.9-alpine

RUN apk update
RUN pip3 install --no-cache-dir pipenv

WORKDIR /usr/src/app

COPY Pipfile Pipfile.lock bootstrap.sh ./
COPY app ./app

RUN pipenv install

EXPOSE 5000
ENTRYPOINT ["/usr/src/bootstrap.sh"]