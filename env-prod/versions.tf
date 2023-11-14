terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }

    time = {
      source = "hashicorp/time"
      version = "0.9.1"
    }

  }
}

  