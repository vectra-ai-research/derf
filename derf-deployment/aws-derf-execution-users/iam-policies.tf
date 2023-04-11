resource "aws_iam_user_policy" "derf_execution_user_policy_01" {
  name   = "derf-execution-user-policy-01"
  user   = aws_iam_user.derf_execution_user_01.name
  policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "iam:Get*",
            "iam:List*",
            "iam:Generate*"
        ],
        "Resource": "*"
    }
})
    
}
resource "aws_iam_user_policy" "derf_execution_user_policy_02" {
  name   = "derf-execution-user-policy-02"
  user   = aws_iam_user.derf_execution_user_02.name
  policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "iam:Get*",
            "iam:List*",
            "iam:Generate*"
        ],
        "Resource": "*"
    }
})
    
}