import os
import time
import subprocess
from flask import Flask, json, request, abort, jsonify
import requests as requests
app = Flask(__name__)

@app.route('/resetRange', methods=['GET','POST'])
def resetRange():
  data = request.json
  if 'HOST' not in data:
    abort(400, description='missing HOST')
  elif 'REGION' not in data:
    abort(400, description='missing REGION')
  elif 'SERVICE' not in data:
    abort(400, description='missing SERVICE')
  elif 'ENDPOINT' not in data:
    abort(400, description='missing ENDPOINT')
  else:
    return terraform_apply(), 200, {'Content-Type': 'application/json; charset=utf-8'}


#return errors as JSON, otherwise it would be HTML
@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400


def terraform_apply():

  accessKeyId = os.environ['AWS_ACCESS_KEY_ID_USER01']
  accessKeySecret = os.environ['AWS_SECRET_ACCESS_KEY_USER01']  
  
  result = subprocess.run(["bash", "-c", "which python"])
  
  return (result)

if __name__ == '__main__':
    app.run() 