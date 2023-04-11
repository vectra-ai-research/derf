resource "aws_iam_user" "derf_execution_user_01" {
  name = "DeRF-Execution-User01"
    tags = {
    derf = "derf-users"
  }
}

resource "aws_iam_user" "derf_execution_user_02" {
  name = "DeRF-Execution-User02"
    tags = {
    derf = "derf-users"
  }
}

