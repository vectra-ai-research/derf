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
    return route_exec(data)


@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400


def route_exec(data):
    
    newuser = data['NEWUSER']
    creds, project = google.auth.default( scopes=['googleapis.com/auth/cloud-platform'])
    gcloud_path = shutil.which("gcloud")

    try:
        completedProcess = subprocess.run("$GCLOUD run services update aws-proxy-app '--update-secrets=AWS_ACCESS_KEY_ID_$NEWUSER=derf-$NEWUSER-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_$NEWUSER=derf-$NEWUSER-accessKeySecret-AWS:latest' --region us-central1 --project derf-deployment-public", 
                                          env={"GCLOUD": gcloud_path, "NEWUSER": newuser},
                                          shell=True, 
                                          stdout=subprocess.PIPE, 
                                          stderr=subprocess.STDOUT, 
                                          timeout=10,
                                          text=True
                                          )
        response = print(completedProcess, 200)
        return response
    except subprocess.TimeoutExpired:
        response = print("Timedout", 400)
        return response

if __name__ == '__main__':
    app.run() 

# def sample_update_service(data):
#     # Create a client
#     client = run_v2.ServicesClient()
#     project_id = os.environ['PROJECT_ID']
#     newuser = data['NEWUSER']

#     # define a service request
#         # define a service request
#     request = run_v2.UpdateServiceRequest(
#         service=run_v2.Service(
#             name="projects/" + project_id + "/locations/us-central1/services/aws-proxy-app",
#             template=run_v2.RevisionTemplate(
#                 containers=[
#                     run_v2.Container(
#                         image="us-docker.pkg.dev/derf-artifact-registry-public/aws-proxy-app/aws-proxy-app:latest",
#                         env=[
#                             run_v2.EnvVar(
#                                 name="AWS_ACCESS_KEY_ID_" + newuser,
#                                 value_source=run_v2.EnvVarSource(
#                                    secret_key_ref=run_v2.SecretKeySelector(
#                                       secret="derf-" + newuser + "-accessKeyId-AWS",
#                                       version="latest",
#                                    ),
#                                 ),
#                             ),
#                         ],
#                     ),
#                 ],
#             ),
#         ),
#     )
    
#     # Make the request
#     operation = client.update_service(request=request)

#     print("Waiting for operation to complete...")

#     response = operation.result()

#     # Handle the response
#     print(response)
#     return(response.traffic_statuses)
