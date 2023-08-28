## Security Groups
resource "aws_security_group" "derf-ec2-open-ingress-22" {
  name        = "derf-ec2-open-ingress-33"
  description = "Security group used and manipulated during the Open Ingress Port 22 on a Security Group Attack Technique"
  vpc_id      = var.vpc_id

  #all outbound
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
  create_before_destroy = true
  }
}