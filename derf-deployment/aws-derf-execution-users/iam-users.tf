########################################################################################
# DeRF Default User - User used for clean-up activities and infrastructure deployments
##########################################################################################

resource "aws_iam_user" "derf_default_user" {
  name = "DeRF-Default-User"
    tags = {
    derf = "derf-default-user"
  }
}


########################################################################################
# DeRF Execution Users - Attacks Run as these Users
##########################################################################################

resource "aws_iam_user" "derf_execution_user_01" {
  name = "DeRF-Execution-User01"
    tags = {
    derf = "derf-execution-users"
  }
}

resource "aws_iam_user" "derf_execution_user_02" {
  name = "DeRF-Execution-User02"
    tags = {
    derf = "derf-execution-users"
  }
}

resource "aws_iam_group" "derf-execution-users" {
  name = "derf-execution-users"
  path = "/"
}

resource "aws_iam_group_membership" "derf-execution-users-group-membership" {
  name = "derf-execution-users-group-membership"

  users = [
    aws_iam_user.derf_execution_user_01.name,
    aws_iam_user.derf_execution_user_02.name,
  ]

  group = aws_iam_group.derf-execution-users.name
}

