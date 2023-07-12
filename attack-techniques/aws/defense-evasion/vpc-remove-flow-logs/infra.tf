locals {
  resource_prefix = "derf-remove-flow-logs"
}

resource "aws_flow_log" "flow-logs" {
  iam_role_arn    = aws_iam_role.role.arn
  log_destination = aws_cloudwatch_log_group.logs.arn
  traffic_type    = "REJECT"
  vpc_id          = var.vpc_id
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/derf/vpc-flow-logs"
}

resource "aws_iam_role" "role" {
  name = "${local.resource_prefix}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  name = "${local.resource_prefix}-policy"
  role = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}