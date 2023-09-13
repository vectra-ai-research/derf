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
  if 'REMOVEUSER' in data:
    response = deleteSecrets(data)
    return print(response)
  elif 'NEWUSER' in data:
    response =  updateSecrets(data)
    return print(response)
  else:
    return abort(400, description='New User not specified')


@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400


def updateSecrets(data):

    projectId = os.environ['PROJECT_ID']
    newuser = data['NEWUSER']
    access_token = get_access_token()
    gcloud_path = shutil.which("gcloud")
    updateSecrets = "--update-secrets=AWS_ACCESS_KEY_ID_" + newuser + "=derf-" + newuser + "-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_" + newuser + "=derf-" + newuser + "-accessKeySecret-AWS:latest"

    try:
        completedProcess = subprocess.run("$GCLOUD run services update aws-proxy-app $UPDATESECRETS --region us-central1 --project $PROJECT_ID --access-token-file $CLOUDSDK_AUTH_ACCESS_TOKEN", 
                                          env={"GCLOUD": gcloud_path, "UPDATESECRETS": updateSecrets, "PROJECT_ID": projectId, "CLOUDSDK_AUTH_ACCESS_TOKEN": access_token},
                                          shell=True, 
                                          timeout=120,
                                          text=True
                                          )
        response = print("New User Created", completedProcess.returncode)
        return response
    except subprocess.CalledProcessError as e:
        response = print("Process Error",e.output)
        return response
    except subprocess.TimeoutExpired as e:
        response = print("Timedout",e.output)
        return response
    finally:
        return print("New User Created")
    

def deleteSecrets(data):
    
    projectId = os.environ['PROJECT_ID']
    removeuser = data['REMOVEUSER']
    access_token = get_access_token()
    gcloud_path = shutil.which("gcloud")
    removeSecrets = "--remove-secrets=AWS_ACCESS_KEY_ID_" + removeuser + ",AWS_SECRET_ACCESS_KEY_" + removeuser

    try:
        completedProcess = subprocess.run("$GCLOUD run services update aws-proxy-app $REMOVESECRETS --region us-central1 --project $PROJECT_ID --access-token-file $CLOUDSDK_AUTH_ACCESS_TOKEN", 
                                          env={"GCLOUD": gcloud_path, "REMOVESECRETS": removeSecrets, "PROJECT_ID": projectId, "CLOUDSDK_AUTH_ACCESS_TOKEN": access_token},
                                          shell=True, 
                                          timeout=120,
                                          text=True
                                          )
        response = print("User Deleted", completedProcess.returncode)
        return response
    except subprocess.CalledProcessError as e:
        response = print("Timedout",e.output)
        return response
    except subprocess.TimeoutExpired as e:
        response = print("Timedout",e.output)
        return response
    finally:
        return print("User Deleted")



def get_access_token():

  METADATA_HEADERS = {'Metadata-Flavor': 'Google'}
  url = 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token'

  # Request an access token from the metadata server.
  r = requests.get(url, headers=METADATA_HEADERS)
  r.raise_for_status()

  # Extract the access token from the response.
  access_token = r.json()['access_token']
  print(access_token)

  return access_token

if __name__ == '__main__':
    app.run() 

