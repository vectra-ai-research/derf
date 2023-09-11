from email import header
import os
import shutil
import google.auth
from flask import Flask, json, request, abort, jsonify
import requests as requests
import subprocess
import shutil
from subprocess import run

app = Flask(__name__)


@app.route('/updateSecrets', methods=['POST'])
def validate_post():
  data = request.json
  print(data)
  if 'NEWUSER' not in data:
    abort(400, description='New User not specified')
  else:
    return updateSecrets(data)


@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400


def updateSecrets(data):
    projectId = os.os.environ['PROJECT_ID']
    newuser = data['NEWUSER']
    creds, project = google.auth.default( scopes=['googleapis.com/auth/cloud-platform'])
    gcloud_path = shutil.which("gcloud")

    try:
        completedProcess = subprocess.run("$GCLOUD run services update aws-proxy-app '--update-secrets=AWS_ACCESS_KEY_ID_'$NEWUSER'=derf-'$NEWUSER'-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_'$NEWUSER'=derf-'$NEWUSER'-accessKeySecret-AWS:latest' --region us-central1 --project $PROJECT_ID", 
                                          env={"GCLOUD": gcloud_path, "NEWUSER": newuser, "PROJECT_ID": projectId},
                                          shell=True, 
                                          stdout=subprocess.PIPE, 
                                          stderr=subprocess.STDOUT, 
                                          timeout=10,
                                          text=True
                                          )
        response = print(completedProcess.returncode, 200)
        return response
    except subprocess.TimeoutExpired:
        response = print("Timedout", 400)
        return response
    return response

if __name__ == '__main__':
    app.run() 

