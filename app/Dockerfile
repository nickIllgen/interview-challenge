# FROM python:3.9-alpine
# WORKDIR /app
# RUN apk update

# EXPOSE 5000/tcp

# COPY ./app/requirements.txt .
# RUN pip3 install -r requirements.txt

# COPY ./app/app.py .
# COPY ./app/helper.py .
# EXPOSE 5000
# CMD [ "python", "./app.py" ]
FROM python:3.8-slim as builder
COPY . /src
RUN pip install --user fastapi uvicorn boto3 flask

FROM python:3.8-slim as app
COPY --from=builder /root/.local /root/.local
COPY --from=builder /src .

ENV PATH=/root/.local:$PATH
EXPOSE 5000

CMD ["python3", "app.py"]