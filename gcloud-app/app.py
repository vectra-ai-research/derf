from email import header
import os
from flask import Flask, json, request, abort, jsonify
import requests as requests
import subprocess
from subprocess import run

app = Flask(__name__)


@app.route('/updateSecrets', methods=['POST'])
def validate_post():
  data = request.json
  print(data)
  if 'NEWUSER' not in data:
    abort(400, description='New User not specified')
  else:
    return update_users()



@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400

def update_users():
  PROJECT_ID = os.environ['--project=' + PROJECT_ID]
  update = subprocess.run(["gcloud", "run", "services", "update", "aws-proxy-app", "--update-secrets=AWS_ACCESS_KEY_ID_RSmith=derf-RSmith-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_RSmith=derf-RSmith-accessKeySecret-AWS:latest", "region=us-central1", "PROJECT_ID"],
    env=PROJECT_ID,
    stdout=subprocess.PIPE, 
    stderr=subprocess.PIPE,
    capture_output=True,
    check=True,
    text=True)
  print(update.stderr)
  return update.stdout

if __name__ == '__main__':
    app.run() 