terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.26.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}


resource "google_storage_bucket" "bucket_1" {
  name          = var.gcs_bucket_name
  location      = var.location
  storage_class = var.gcs_storage_class
  uniform_bucket_level_access = true
  public_access_prevention = "enforced"
}



resource "google_bigquery_dataset" "dataset_1" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}