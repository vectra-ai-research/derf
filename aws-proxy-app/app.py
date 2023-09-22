from email import header
import os
from flask import Flask, json, request, abort, jsonify
from requests_aws4auth import AWS4Auth
from requests_aws4auth import PassiveAWS4Auth
import requests as requests
import xmltodict
from xml.parsers.expat import ExpatError

app = Flask(__name__)


@app.route('/submitRequest', methods=['POST'])
def validate_post():
  data = request.json
  if 'HOST' not in data:
    abort(400, description='missing HOST')
  elif 'REGION' not in data:
    abort(400, description='missing REGION')
  elif 'SERVICE' not in data:
    abort(400, description='missing SERVICE')
  elif 'ENDPOINT' not in data:
    abort(400, description='missing ENDPOINT')
  elif 'VERB' not in data:
    abort(400, description='missing VERB')
  else:
    return submit_request(), 200, {'Content-Type': 'application/json; charset=utf-8'}

#return errors as JSON, otherwise it would be HTML
@app.errorhandler(400)
def bad_request(message):
  return jsonify(error=str(message)), 400


def submit_request():
  data = request.json

## Baseline Headers
  headers = {
              'User-Agent': data['UA'] if 'UA' in data else 'detection-replay-framework',
              'Connection': 'close', 
              'Accept-Encoding': 'gzip, deflate',
              'Host': data['HOST']
             }

## Assign the Content-Type Header for PUT and POST requests
  headers['Content-Type'] = data['CONTENT'] if 'CONTENT' in data else print("no CONTENT parameter provided")


## Handle setting the Body for PUT and POST requests
  body = data['BODY'] if 'BODY' in data else ''


## Set the TARGET Header for unique AWS services which use this value for routing.
  headers['X-Amz-Target'] = data['TARGET'] if 'TARGET' in data else print("no TARGET parameter provided")

# S3 Configurations
## Assign S3 headers during copy events.
  headers['x-amz-copy-source'] = data['SOURCEBUCKET'] if 'SOURCEBUCKET' in data else print("no SOURCEBUCKET parameter provided")


## Assign headers associated with the assignment of canned ACLs
  headers['x-amz-acl'] = data['ACL'] if 'ACL' in data else ''


## Assign headers associated with non-cannned, grantee ACLs.
  headers['x-amz-grant-read'] = data['GRANTREADACL'] if 'GRANTREADACL' in data else print("no GRANTREADACL parameter provided")
  headers['x-amz-grant-write'] = data['GRANTWRITEACL'] if 'GRANTWRITEACL' in data else print("no GRANTWRITEACL parameter provided")
  headers['x-amz-grant-full-control'] = data['GRANTFULLACL'] if 'GRANTFULLACL' in data else print("no GRANTFULLACL parameter provided")     

## Handle headers associated with KMS encryption.
  headers['x-amz-server-side-encryption'] = data['SSE'] if 'SSE' in data else print("no SSE parameter provided")
  headers['x-amz-server-side-encryption-aws-kms-key-id'] = data['KMS-KEY-ID'] if 'KMS-KEY-ID' in data else print("no KMS-KEY-ID parameter provided")

## Handle the 'USER' parameter so the detection can be run as different users
  try:
    if (data['USER'] is not ("", [], None, 0, False)):
      print("Accessing keys for user specified in 'user' parameter")
      accessKeyId = os.environ['AWS_ACCESS_KEY_ID_' + data['USER']]
      accessKeySecret = os.environ['AWS_SECRET_ACCESS_KEY_' + data['USER']]
      auth = AWS4Auth(accessKeyId,accessKeySecret, data['REGION'], data['SERVICE'])  
    elif (data['USER'] is ("", [], None, 0, False)):
      print("Accessing keys for default user with ELSE block")
      accessKeyId = os.environ['AWS_ACCESS_KEY_ID']
      accessKeySecret = os.environ['AWS_SECRET_ACCESS_KEY']
      auth = AWS4Auth(accessKeyId,accessKeySecret, data['REGION'], data['SERVICE'])
  except:
      print("Finding user in request, except block")
      accessKeyId = os.environ['AWS_ACCESS_KEY_ID']
      accessKeySecret = os.environ['AWS_SECRET_ACCESS_KEY']
      auth = AWS4Auth(accessKeyId,accessKeySecret, data['REGION'], data['SERVICE'])

## Handle the passing of temporary session credentials directly to the app so the detection can be 
## run as a role on the fly

  try:
    if data['TEMPCREDSPASSED'] == "yes":
      print("if TEMPCREDSPASSED == YES")
      accessKeyId = data['ACCESSKEYID']
      accessKeySecret = data['ACCESSKEYSECRET']
      accessKeySessionToken = data['SESSIONTOKEN']
      auth = AWS4Auth(accessKeyId,accessKeySecret, data['REGION'], data['SERVICE'], session_token=accessKeySessionToken)
    else:
      print("if TEMPCREDSPASSED else")
      accessKeyId = os.environ['AWS_ACCESS_KEY_ID']
      accessKeySecret = os.environ['AWS_SECRET_ACCESS_KEY']
      auth = AWS4Auth(accessKeyId,accessKeySecret, data['REGION'], data['SERVICE'])
  except:
      print("if TEMPCREDSPASSED except")
  #     accessKeyId = os.environ['AWS_ACCESS_KEY_ID']
  #     accessKeySecret = os.environ['AWS_SECRET_ACCESS_KEY']
  #     auth = AWS4Auth(accessKeyId,accessKeySecret, data['REGION'], data['SERVICE']) 
  


## POST HTTP Requests
  if data['VERB'] == 'POST':

    response = requests.post(data['ENDPOINT'], data=body, headers=headers, auth=auth)
    print(response.request)
    responseHeaders = response.headers
    print(responseHeaders)
    contentType = responseHeaders['content-type'] if 'content-type' in responseHeaders else ''

    if "application/json" in contentType:
      try:
        jsonResponse = response.json()
      except:
        print("In except block 1")
        jsonResponse = json.dumps({})
    elif "x-amz-json-1.1" in contentType:
      try:
        print("In TRY block 2")
        jsonResponse = response.json()
      except:
        print("In except block 2")
        jsonResponse = json.dumps({})
    elif "text/xml" in contentType:
        try:
          print("In TRY block 3")
          jsonResponse = xmltodict.parse(response.text)
        except (xmltodict.ParsingInterrupted, ExpatError):
          print("In except block 3")
          jsonResponse = str(response.text.strip())
    else:
        try:
          print("In TRY block 4")
          jsonResponse = json.dumps(xmltodict.parse(response.text))
        except (xmltodict.ParsingInterrupted, ExpatError):
          print("In except block 4")
          jsonResponse = str(response.text.strip())





## PUT HTTP Requests
  elif data['VERB'] == 'PUT':
    response = requests.put(data['ENDPOINT'], data=body, headers=headers, auth=auth)
    print(response.request)
    responseHeaders = response.headers
    print(responseHeaders)
    contentType = responseHeaders['content-type'] if 'content-type' in responseHeaders else ''

    if "application/json" in contentType:
      try:
        print("PUT: In TRY block 1")
        jsonResponse = response.json()
      except:
        print("PUT: In except block 1")
        jsonResponse = json.dumps({})
    elif "x-amz-json-1.1" in contentType:
      try:
        print("PUT: In TRY block 2")
        jsonResponse = response.json()
      except:
        print("PUT: In except block 2")
        jsonResponse = json.dumps({})
    elif "text/xml" in contentType:
        try:
          print("PUT: In TRY block 3")
          jsonResponse = xmltodict.parse(response.text)
        except (xmltodict.ParsingInterrupted, ExpatError):
          print("PUT: In except block 3")
          jsonResponse = str(response.text.strip())
    else:
        try:
          print("PUT: In TRY block 4")
          jsonResponse = json.dumps(xmltodict.parse(response.text))
        except (xmltodict.ParsingInterrupted, ExpatError):
          print("PUT: In except block 4")
          jsonResponse = str(response.text.strip())

  


## DELETE HTTP Requests
  elif data['VERB'] == 'DELETE':
      queryParameters = data['queryParameters'] if 'queryParameters' in data else ''

      response = requests.delete(data['ENDPOINT'], params=queryParameters, headers=headers, auth=auth)
      print(response.request)
      responseHeaders = response.headers
      print(responseHeaders)
      contentType = responseHeaders['content-type'] if 'content-type' in responseHeaders else ''

      if "application/json" in contentType:
        try:
          print("In TRY block 1")
          jsonResponse = response.json()
        except:
          print("In except block 1")
          jsonResponse = json.dumps({})
      elif "x-amz-json-1.1" in contentType:
        try:
          print("In TRY block 2")
          jsonResponse = response.json()
        except:
          print("In except block 2")
          jsonResponse = json.dumps({})
      elif "text/xml" in contentType:
          try:
            print("In TRY block 3")
            jsonResponse = xmltodict.parse(response.text)
          except (xmltodict.ParsingInterrupted, ExpatError):
            print("In except block 3")
            jsonResponse = str(response.text.strip())
      else:
          try:
            print("In TRY block 4")
            jsonResponse = json.dumps(xmltodict.parse(response.text))
          except (xmltodict.ParsingInterrupted, ExpatError):
            print("In except block 4")
            jsonResponse = str(response.text.strip())



## GET HTTP Requests
  elif data['VERB'] == 'GET':
    queryParameters = data['queryParameters'] if 'queryParameters' in data else ''
    response = requests.get(data['ENDPOINT'], params=queryParameters, headers=headers, auth=auth)
    
    print(response.request)
    responseHeaders = response.headers
    print(responseHeaders)
    contentType = responseHeaders['content-type'] if 'content-type' in responseHeaders else ''

    if "application/json" in contentType:
      try:
        print("In TRY block 1")
        jsonResponse = response.json()
      except:
        print("In except block 1")
        jsonResponse = json.dumps({})
    elif "x-amz-json-1.1" in contentType:
      try:
        print("In TRY block 2")
        jsonResponse = response.json()
      except:
        print("In except block 2")
        jsonResponse = json.dumps({})
    elif "text/xml" in contentType:
        try:
          print("In TRY block 3")
          jsonResponse = xmltodict.parse(response.text)
        except (xmltodict.ParsingInterrupted, ExpatError):
          print("In except block 3")
          jsonResponse = str(response.text.strip())
    else:
        try:
          print("In TRY block 4")
          jsonResponse = json.dumps(xmltodict.parse(response.text))
        except (xmltodict.ParsingInterrupted, ExpatError):
          print("In except block 4")
          jsonResponse = str(response.text.strip())

          
## Else throw an error about an incorrect or missing VERB parameter.
  else:
    print("final else block in VERB processing") 
    response = "Error - Unable to send the HTTP to AWS request with the provided Method"


## Return response
  print(jsonResponse);
  if response.status_code:
      print("if response.status_code")
      Result = {"responseBody":jsonResponse,"responseCode":response.status_code}
      print(Result);
  else:
      print("else block when returning result")
      Result = "Error in executing request in AWS"

  return Result

if __name__ == '__main__':
    app.run() 