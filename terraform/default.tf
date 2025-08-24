terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}


locals {
  project_id = "flask-app-project-469909" 
  region     = "us-central1"
  zone       = "us-central1-a"
}

# Провайдер Google Cloud
provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}