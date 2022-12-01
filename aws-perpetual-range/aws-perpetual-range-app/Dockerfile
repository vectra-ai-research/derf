FROM docker.mirror.hashicorp.services/golang:alpine
LABEL maintainer="HashiCorp Terraform Team <terraform@hashicorp.com>"

RUN apk add --no-cache git bash openssh
RUN apk add python3-pip

RUN pip3 install --upgrade pip
RUN python3 -V
RUN pip --version
# Install python packages
RUN pip install flask boto3 botocore requests gunicorn

ENV TF_DEV=true
ENV TF_RELEASE=1

WORKDIR $GOPATH/src/github.com/hashicorp/terraform
COPY . .
RUN /bin/bash ./scripts/build.sh


################################
# Install AWS CLI
################################
RUN pip install awscli --upgrade --user

# add aws cli location to path
ENV PATH=~/.local/bin:$PATH

RUN mkdir ~/.aws && touch ~/.aws/credentials

# Copy local code to the container image.
ENV APP_HOME /
WORKDIR $APP_HOME
COPY . ./

# Run the web service on container startup.
# Use gunicorn webserver with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 --log-level=debug app:app