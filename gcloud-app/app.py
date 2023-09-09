from email import header
import os
import shutil
from flask import Flask, json, request, abort, jsonify
import requests as requests
import subprocess
from subprocess import run
from google.cloud import run_v2

app = Flask(__name__)


@app.route('/updateSecrets', methods=['POST'])
def validate_post():
  data = request.json
  print(data)
  if 'NEWUSER' not in data:
    abort(400, description='New User not specified')
  else:
    return sample_update_service(data)



@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400


def sample_update_service(data):
    # Create a client
    client = run_v2.ServicesClient()

    # Initialize request argument(s)
    request = run_v2.UpdateServiceRequest(
       Service = {
          name  = "aws-proxy-app"
          template {
             containers = {
                image = "us-docker.pkg.dev/derf-artifact-registry-public/aws-proxy-app/aws-proxy-app:latest"
                env [
                   name = 
                   value_source {
                      secret_key_ref {
                         secret = 
                         version = latest
                      }
                   }
                ]
             }
          }

       }
    )

    # Make the request
    operation = client.update_service(request=request)

    print("Waiting for operation to complete...")

    response = operation.result()

    # Handle the response
    print(response)

# [END run_v2_generated_Services_UpdateService_sync]

# def update_users(data):
#   projectFlag = "--project " + os.environ['PROJECT_ID']
#   print(projectFlag)
#   USER = data['NEWUSER']
#   print(USER)
#   GCLOUD_PATH = shutil.which("gcloud")
#   print(GCLOUD_PATH)
#   # updateSecrets = "--update-secrets=AWS_ACCESS_KEY_ID_" + USER + "=derf-" + USER + "-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_" + USER + "=derf-" + USER "-accessKeySecret-AWS:latest"
#   # print(updateSecrets)
#   # env = {
#   #   "projectFlag": projectFlag,
#   #   "USER": USER
#   #            }
#   update = subprocess.run(['curl', '-o', 'email.out', "--header", "Metadata-Flavor: Google", "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email"],
#     env = {"projectFlag": projectFlag, "USER": USER, "GCLOUD": GCLOUD_PATH},
#     shell=True,
#     stdout=subprocess.PIPE, 
#     stderr=subprocess.PIPE,
#     check=True,
#     text=True)
#   print(update.returncode, update.stdout, update.stderr)
#   return update.stdout

if __name__ == '__main__':
    app.run() 