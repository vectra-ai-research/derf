locals {
    aws_accounts = {
        "primary" = var.aws_primary_id
        "secondardy" = var.aws_secondary_id
}
gcp_projects = {
    "derf-deployment" = "derf-deployment"
}

}