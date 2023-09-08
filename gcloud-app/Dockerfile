# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.9-slim

# Allow statements and log messages to immediately appear in the Cloud Run logs
ENV PYTHONUNBUFFERED True

# Install python packages
RUN pip install flask requests gunicorn requests-aws4auth subprocess

# Copy local code to the container image.
ENV APP_HOME /
WORKDIR $APP_HOME
COPY ./gcloud-app/ .

# Run the web service on container startup.
# Use gunicorn webserver with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app