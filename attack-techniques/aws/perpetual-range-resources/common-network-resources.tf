## Network Resources

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "derf-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.105.0/24", "10.0.106.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

}


## Security Groups
resource "aws_security_group" "derf-ec2-with-ssm" {
  name        = "derf-ec2-with-ssm-sg"
  description = "Security group rules for EC2 accessible via SSM."
  vpc_id      = module.vpc.vpc_id

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