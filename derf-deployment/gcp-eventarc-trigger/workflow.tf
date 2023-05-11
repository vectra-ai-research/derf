data "google_service_account" "workflows-to-cloudbuild-sa" {
  account_id   = "workflows-to-cloudbuild-sa"
  project = var.gcp_deployment_project_id
  depends_on = [ google_service_account.workflows-to-cloudbuild-service-account ]

}

resource "google_workflows_workflow" "workflow_to_run_cloudbuild_trigger" {
  name            = "run-cloudbuild-trigger"
  description     = "A workflow intended run and approve the derf cloudbuild trigger when it is first created"
  service_account = data.google_service_account.workflows-to-cloudbuild-sa.id
  project         = var.gcp_deployment_project_id
  depends_on = [ 
    google_project_iam_member.project_iam_assignment1_workflow_cmsa,
    google_project_iam_member.project_iam_assignment2_workflow_cmsa
   ]
  source_contents = <<-EOF
  
######################################################################################
## Main Workflow Execution
######################################################################################
main:
  steps:
    - GetTriggerId:
        call: GetTriggerId
        result: triggerId  
    - RunTrigger:
        call: RunTrigger
        args:
            triggerId: $${triggerId}
        result: runResult
    - GetBuildId:
        call: GetBuildId
        result: buildId
    - ApproveBuild:
        call: ApproveBuild
        args:
            buildId: $${buildId}
        result: approveBuildResult                
    - return:
        return: $${approveBuildResult}



######################################################################################
## Submodules | Sub-Workflows
######################################################################################
GetTriggerId:
  steps: 
    - getTriggerId:
        call: googleapis.cloudbuild.v1.projects.locations.triggers.list
        args:
            parent: "projects/${var.gcp_deployment_project_id}/locations/global"
            pageSize: 1
            projectId: ${var.gcp_deployment_project_id}
        result: triggerId
    - return:
        return: $${triggerId.triggers[0].id}

RunTrigger:
  params: [triggerId]
  steps: 
    - runTrigger:
        call: googleapis.cloudbuild.v1.projects.locations.triggers.run
        args:
            name: "projects/${var.gcp_deployment_project_id}/locations/global/triggers/Github-Trigger-derf-aws-proxy-app-repo-main"
            connector_params:
                timeout: 31536000
                skip_polling: True    
            body:
                projectId: "${var.gcp_deployment_project_id}"
                source:
                    branchName: "main"
                    repoName: "derf"
                triggerId: "$${triggerId}"
        result: runResult
    - return:
        return: $${runResult}   

GetBuildId:
  steps: 
    - getBuildId:
        call: googleapis.cloudbuild.v1.projects.builds.list
        args:
            parent: "projects/${var.gcp_deployment_project_id}/locations/global"
            pageSize: 1
            projectId: ${var.gcp_deployment_project_id}
        result: response
    - return:
        return: $${response.builds[0].id}


ApproveBuild:
  params: [buildId]
  steps: 
    - approveBuild:
        call: googleapis.cloudbuild.v1.projects.builds.approve
        args:
            name: $${"projects/${var.gcp_deployment_project_id}/builds/"+buildId}
            body:
                approvalResult:
                    decision: APPROVED
        result: approveBuildResult
    - return:
        return: $${"approveBuildResult"} 



  EOF

}
