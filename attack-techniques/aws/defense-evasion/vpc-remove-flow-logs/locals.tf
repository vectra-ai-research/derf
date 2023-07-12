locals {
  flow_id           = aws_flow_log.flow-logs.id
  log_delivery_arn  = aws_iam_role.role.arn
}