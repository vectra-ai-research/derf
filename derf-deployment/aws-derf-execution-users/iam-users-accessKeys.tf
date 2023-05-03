resource "aws_iam_access_key" "derf_execution_user_01_key" {
  user = aws_iam_user.derf_execution_user_01.name
}

resource "aws_iam_access_key" "derf_execution_user_02_key" {
  user = aws_iam_user.derf_execution_user_02.name
}

resource "aws_iam_access_key" "derf_default_user_key" {
  user = aws_iam_user.derf_default_user.name
}