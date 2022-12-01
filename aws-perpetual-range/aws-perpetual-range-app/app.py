import os
import time
import subprocess
from flask import Flask, json, request, abort, jsonify
import requests as requests
app = Flask(__name__)

@app.route('/apply', methods=['GET'])
def resetRange():
  return terraform_apply(), 200, {'Content-Type': 'application/json; charset=utf-8'}


def terraform_apply():

  accessKeyId = os.environ['AWS_ACCESS_KEY_ID_USER01']
  accessKeySecret = os.environ['AWS_SECRET_ACCESS_KEY_USER01']  
  
  result = subprocess.run(["bash", "-c", "which python"])
  
  return (result)

if __name__ == '__main__':
    app.run() 