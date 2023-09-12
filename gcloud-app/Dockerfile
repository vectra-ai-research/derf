# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.9-slim

# Allow statements and log messages to immediately appear in the Cloud Run logs
ENV PYTHONUNBUFFERED True

# Install python packages
RUN pip install flask requests gunicorn google.auth


RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
        curl 

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing gcloud
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh --quiet 

# Adding the gcloud path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
RUN chmod -R 777 /usr/local/gcloud/google-cloud-sdk/bin


# Copy local code to the container image.
ENV APP_HOME /
WORKDIR $APP_HOME
COPY ./gcloud-app/ .
USER root

# Run the web service on container startup.
# Use gunicorn webserver with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app