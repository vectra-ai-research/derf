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
    if 'REMOVEUSER' in data == '*':
      return resetApp()
    else:
      return deleteSecrets(data)
  elif 'NEWUSER' in data:
    return updateSecrets(data)
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
                                          timeout=180,
                                          text=True
                                          )
        response = print("New User Created")
        return response
    except subprocess.CalledProcessError as e:
        response = print("Process error when creating new user")
        return response
    except subprocess.TimeoutExpired as e:
        response = print("Creation of new user timed out")
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
                                          timeout=180,
                                          text=True
                                          )

        response = print("User Deleted")
        return response
    except subprocess.CalledProcessError as e:
        response = print("Process error when deleting user")
        return response
    except subprocess.TimeoutExpired as e:
        response = print("Unable to delete user, process timedout")
        return response
    finally:
        return print("User Deleted")

def resetApp():
    projectId = os.environ['PROJECT_ID']
    access_token = get_access_token()
    gcloud_path = shutil.which("gcloud")
    setSecrets = "--set-secrets=AWS_ACCESS_KEY_ID=projects/$PROJECT_NUMBER/secrets/derf-default-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY=projects/$PROJECT_NUMBER/secrets/derf-default-accessKeySecret-AWS:latest,AWS_ACCESS_KEY_ID_USER02=projects/$PROJECT_NUMBER/secrets/derf-user02-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_USER02=projects/$PROJECT_NUMBER/secrets/derf-user02-accessKeySecret-AWS:latest,AWS_ACCESS_KEY_ID_USER01=projects/$PROJECT_NUMBER/secrets/derf-user01-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_USER01=projects/$PROJECT_NUMBER/secrets/derf-user01-accessKeySecret-AWS:latest"

    try:
        completedProcess = subprocess.run("$GCLOUD run services update aws-proxy-app $SETSECRETS --region us-central1 --project $PROJECT_ID --access-token-file $CLOUDSDK_AUTH_ACCESS_TOKEN", 
                                          env={"GCLOUD": gcloud_path, "SETSECRETS": setSecrets, "PROJECT_ID": projectId, "CLOUDSDK_AUTH_ACCESS_TOKEN": access_token},
                                          shell=True, 
                                          timeout=180,
                                          text=True
                                          )

        response = print("Proxy app redeployed and reset to original configuration")
        return response
    except subprocess.CalledProcessError as e:
        response = print("Process error when deleting users")
        return response
    except subprocess.TimeoutExpired as e:
        response = print("Unable to delete user, process timedout")
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

