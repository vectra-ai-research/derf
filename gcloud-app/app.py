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
    return update_users(data)



@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400

def update_users(data):
  projectFlag = "--project=" + os.environ['PROJECT_ID']
  updateSecrets = "--update-secrets=AWS_ACCESS_KEY_ID_" + data['NEWUSER'] + "=derf-" + data['NEWUSER'] + "-accessKeyId-AWS:latest,AWS_SECRET_ACCESS_KEY_" + data['NEWUSER'] + "=derf-" + data['NEWUSER'] "-accessKeySecret-AWS:latest"
  update = subprocess.run(["gcloud", "run", "services", "update", "aws-proxy-app", "%updateSecrets%", "region=us-central1", "%projectFlag%"],
    env=projectFlag,
    env=updateSecrets,
    stdout=subprocess.PIPE, 
    stderr=subprocess.PIPE,
    capture_output=True,
    check=True,
    text=True)
  print(update.stderr)
  return update.stdout

if __name__ == '__main__':
    app.run() 