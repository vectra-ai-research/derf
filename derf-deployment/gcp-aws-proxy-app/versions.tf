terraform {
  required_providers {
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