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

    ## Get access token from metadata server
    url = "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
    req = urllib.request.Request(url)
    req.add_header("Metadata-Flavor", "Google")
    r = urllib.request.urlopen(req)
    # print(f.read().decode('utf-8'))
    access_token = r.read().decode()
    json_access_token = jsonify(access_token)
    print(json_access_token["access_token"])

    ## Write access token to file
    # f = open('~/.config/gcloud/access_token.txt', 'w')
    # f.write(access_token.access_token)

    gcloud_path = shutil.which("gcloud")
    updateSecrets = "--update-secrets=AWS_ACCESS_KEY_ID_" + newuser + "=derf-" + newuser + "-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_" + newuser + "=derf-" + newuser + "-accessKeySecret-AWS:latest"

    try:
        completedProcess = subprocess.run("$GCLOUD run services update aws-proxy-app $UPDATESECRETS --region us-central1 --project $PROJECT_ID --access-token-file $CLOUDSDK_AUTH_ACCESS_TOKEN", 
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

