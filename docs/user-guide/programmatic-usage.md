1. Ensure the Google command line tool is installed locally.  Reference Google maintained [documentation](https://cloud.google.com/sdk/docs/install) for instructions on installing `gcloud cli`
2. Authenticate to Google Cloud Project which DeRF is deployed
``` bash
gcloud auth login --project PROJECT-ID
```
1. Invoke a particular attack techniques' workflow with the `gcloud cli`. See Google [documentation](https://cloud.google.com/sdk/gcloud/reference/workflows/run) for more complete instructions on the workflows service.
``` bash
gcloud workflows run WORKFLOW-NAME `--data={"user": "user01"}` 
```

