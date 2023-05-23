terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
      configuration_aliases = [
        aws.primary, aws.secondary
      ]
    }
    
    google = {
      source  = "hashicorp/google"
      version = ">= 4.62.1"
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

  