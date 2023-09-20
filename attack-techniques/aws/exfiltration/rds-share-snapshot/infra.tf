resource "random_password" "password" {
  length    = 32
  min_lower = 32
  special   = false
}


data "aws_availability_zones" "available" {
  state = "available"
}

## Create RDS db instance and a snapshot
resource "aws_db_instance" "default" {
  allocated_storage       = 10 
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                    = "derfRDSInstance"
  backup_retention_period = 0
  db_subnet_group_name    = var.database_subnet_name
  username                = "derf"
  password                = random_password.password.result
  skip_final_snapshot     = true
  apply_immediately       = true
}

resource "aws_db_snapshot" "snapshot" {
  db_instance_identifier = aws_db_instance.default.identifier
  db_snapshot_identifier = "derf-rds-snapshot-share"
  depends_on = [ aws_db_instance.default ]
}
