from email import header
import os
import urllib.request
import urllib.parse
import shutil
import google.auth
from google.auth import compute_engine
import google.auth.transport.requests
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
  if 'REMOVEUSER' in data:
    return deleteSecrets(data)
  else:
    return updateSecrets(data)


@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400


def updateSecrets(data):

    projectId = os.environ['PROJECT_ID']
    newuser = data['NEWUSER']
    url = "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
    req = urllib.request.Request(url)
    req.add_header("Metadata-Flavor", "Google")
    f = urllib.request.urlopen(req)
    print(f.read().decode('utf-8'))
    access_token = f.read().decode('utf-8')
    # access_token = access_token_map['access_token']
    print(access_token)
    # Get Google Creds
    # credentials, project = google.auth.default( scopes=['googleapis.com/auth/cloud-platform'])
    # if credentials.valid:
    #   print("Credentials valid")
    # else:
    #   request = google.auth.transport.requests.Request()
    #   credentials.refresh(request=request)
    # print(credentials.token)
    # token = credentials.token
    ##

    gcloud_path = shutil.which("gcloud")
    updateSecrets = "--update-secrets=AWS_ACCESS_KEY_ID_" + newuser + "=derf-" + newuser + "-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_" + newuser + "=derf-" + newuser + "-accessKeySecret-AWS:latest"

    try:
        completedProcess = subprocess.run("$PWD", 
                                          env={"GCLOUD": gcloud_path, "UPDATESECRETS": updateSecrets, "PROJECT_ID": projectId, "CLOUDSDK_AUTH_ACCESS_TOKEN": access_token},
                                          shell=True, 
                                          stdout=subprocess.PIPE, 
                                          stderr=subprocess.STDOUT, 
                                          timeout=10,
                                          text=True
                                          )
        response = print(completedProcess.returncode, completedProcess.stdout, 200)
        return response
    except subprocess.TimeoutExpired:
        response = print("Timedout", 400)
        return response
    

def deleteSecrets(data):
    
    projectId = os.environ['PROJECT_ID']
    removeuser = data['REMOVEUSER']
    creds, project = google.auth.default( scopes=['googleapis.com/auth/cloud-platform'])
    gcloud_path = shutil.which("gcloud")

    try:
        completedProcess = subprocess.run("$PWD", 
                                          env={"GCLOUD": gcloud_path, "REMOVEUSER": removeuser, "PROJECT_ID": projectId},
                                          shell=True, 
                                          stdout=subprocess.PIPE, 
                                          stderr=subprocess.STDOUT, 
                                          timeout=10,
                                          text=True
                                          )
        response = print(completedProcess.returncode, completedProcess.stdout, 200)
        return response
    except subprocess.TimeoutExpired:
        response = print("Timedout", 400)
        return response

if __name__ == '__main__':
    app.run() 

