## Service: aws-cryptomining-detection
Containerized python application that retrieves credentials from an EC2 instance using AWS System Manager.  Then, with the extracted credentials, starts several 'high-powered', GPU driven EC2 instances.  After instances come online, they are terminated.
- Authentication: Credentials are harvested out of the EC2 instances using the standard AWS User with an Access Key.  In the `vectra-sr` AWS account, that User is named `Detection-Replay-Framework`.  The Access Key Id and Access Key Secret are stored as GCP Secrets and accessed as environment variables at runtime. Further actions are authenticated with the EC2 credentials.
- Cloud Run URL: https://aws-cryptomining-detection-26zheokx5q-uc.a.run.app 
- [Cloud Source Repo](https://source.cloud.google.com/vectra-sr-workflows/aws-cryptomining-detection)
- Endpoint: '/executeDetection'
- Input: User
  - Example:
    - {"USER":"user01"}
- Output: A list containing the (2) instance Ids of the EC2 which were created in `us-east-2` and subsequently deleted.  