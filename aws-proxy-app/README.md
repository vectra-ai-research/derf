## Service: aws-submit-request-asUser
Containerized python application that submits authenticated requests to AWS APIs. This is an all purpose app and can handle any http method.  The HTTP Verb is passed as a parameter to the application.
- Authentication: Configured to AWS as an AWS User with an Access Key.  In the `vectra-sr` AWS account, that User is named `Detection-Replay-Framework`.  The Access Key Id and Access Key Secret are stored as GCP Secrets and accessed as environment variables at runtime.
- Cloud Run URL: https://aws-submit-request-asuser-26zheokx5q-uc.a.run.app
- [Cloud Source Repo]: https://source.cloud.google.com/vectra-sr-workflows/aws-submit-request-asuser
- Endpoint: '/submitRequest'
- Input: Host, Service, Region, Endpoint URL and User-Agent (UA), Verb.
- Output: An Array containing first the Response Body and second the Response Code from the AWS Request.