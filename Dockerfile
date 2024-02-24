FROM python:3.11-bullseye
WORKDIR /usr/src/app

COPY app.py .
RUN ["pip", "install", "-r", "requirements.txt"]

ENTRYPOINT ["python3", "app.py"]