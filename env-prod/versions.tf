terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
      configuration_aliases = [
        aws.primary
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

  }
}

  