output "ACTION_REQUIRED" {
  value       = "Upon successful installation of the DeRF, navigate the the CloudBuild console in your GCP Project (https://console.cloud.google.com/cloud-build/triggers) and click on 'Triggers' and find the 'Github-Trigger-derf-aws-proxy-app-repo-main' Trigger.  Select 'Run' to invoke this Trigger.  Then click on the 'History' tab to approve the build. This will deploy the CORRECT image into Cloud Run. If you don't manually run this on initial deployment, your aws-proxy-app will not work. Only required on first deployment."

}