terraform {
  backend "s3" {
    region         = "us-east-1"
    encrypt        = true
    key            = "terraform.tfstate"
    profile        = "${var.aws_primary_profile}"
  }
}
